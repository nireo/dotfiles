import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

const PROVIDER_ID = "openai-codex";

interface WhamUsageWindow {
	reset_at?: number;
	used_percent?: number;
	limit_window_seconds?: number;
}

interface WhamUsageResponse {
	rate_limit?: {
		primary_window?: WhamUsageWindow;
		secondary_window?: WhamUsageWindow;
	};
}

export interface UsageWindow {
	usedPercent?: number;
	resetAt?: number;
	windowSeconds?: number;
}

export interface UsageSnapshot {
	primary?: UsageWindow;
	secondary?: UsageWindow;
	fetchedAt: number;
}

export interface UsageSummaryWindowsConfig {
	primary: {
		enabled: boolean;
		label: string;
	};
	secondary: {
		enabled: boolean;
		label: string;
	};
}

function normalizeUsedPercent(value?: number): number | undefined {
	if (typeof value !== "number" || !Number.isFinite(value)) return undefined;
	return Math.min(100, Math.max(0, value));
}

function normalizeResetAt(value?: number): number | undefined {
	if (typeof value !== "number" || !Number.isFinite(value)) return undefined;
	return value * 1000;
}

function normalizeWindowSeconds(value?: number): number | undefined {
	if (typeof value !== "number" || !Number.isFinite(value) || value <= 0) return undefined;
	return value;
}

function parseUsageWindow(window?: WhamUsageWindow): UsageWindow | undefined {
	if (!window) return undefined;
	const usedPercent = normalizeUsedPercent(window.used_percent);
	const resetAt = normalizeResetAt(window.reset_at);
	const windowSeconds = normalizeWindowSeconds(window.limit_window_seconds);
	if (usedPercent === undefined && resetAt === undefined && windowSeconds === undefined) return undefined;
	return { usedPercent, resetAt, windowSeconds };
}

const FIVE_HOUR_SECONDS = 5 * 60 * 60;
const WEEK_SECONDS = 7 * 24 * 60 * 60;
const WINDOW_DURATION_TOLERANCE_SECONDS = 120;

function hasWindowDuration(window: UsageWindow, expectedSeconds: number): boolean {
	return window.windowSeconds !== undefined
		&& Math.abs(window.windowSeconds - expectedSeconds) <= WINDOW_DURATION_TOLERANCE_SECONDS;
}

/** Classify windows by duration; primary/secondary ordering is not stable across plans. */
function parseUsageSnapshot(data: WhamUsageResponse): Omit<UsageSnapshot, "fetchedAt"> {
	const windows = [
		parseUsageWindow(data.rate_limit?.primary_window),
		parseUsageWindow(data.rate_limit?.secondary_window),
	].filter((window): window is UsageWindow => window !== undefined);

	return {
		primary: windows.find((window) => hasWindowDuration(window, FIVE_HOUR_SECONDS)),
		secondary: windows.find((window) => hasWindowDuration(window, WEEK_SECONDS)),
	};
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

function readStoredProviderCredential(providerId: string): unknown {
	try {
		const data = JSON.parse(readFileSync(join(getAgentDir(), "auth.json"), "utf-8")) as unknown;
		if (!isRecord(data)) return undefined;
		return data[providerId];
	} catch {
		return undefined;
	}
}

type ResolvedCodexAuth = {
	accessToken: string;
	accountId?: string;
};

const OPENAI_AUTH_CLAIM = "https://api.openai.com/auth";
const OPENAI_ACCOUNT_ID_CLAIM = "https://api.openai.com/auth.chatgpt_account_id";

function decodeJwtPayload(token: string): Record<string, unknown> | undefined {
	const payload = token.split(".")[1];
	if (!payload) return undefined;

	try {
		const parsed: unknown = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
		return isRecord(parsed) ? parsed : undefined;
	} catch {
		return undefined;
	}
}

/** Derive the account id from the selected account's access token. */
function getTokenAccountId(token: string): string | undefined {
	const payload = decodeJwtPayload(token);
	const auth = isRecord(payload?.[OPENAI_AUTH_CLAIM])
		? payload[OPENAI_AUTH_CLAIM]
		: undefined;
	const value = payload?.[OPENAI_ACCOUNT_ID_CLAIM] ?? auth?.chatgpt_account_id;
	return typeof value === "string" && value.trim() ? value.trim() : undefined;
}

function getHeader(headers: unknown, name: string): string | undefined {
	if (!isRecord(headers)) return undefined;
	const target = name.toLocaleLowerCase();
	for (const [key, value] of Object.entries(headers)) {
		if (key.toLocaleLowerCase() === target && typeof value === "string" && value.trim()) {
			return value.trim();
		}
	}
	return undefined;
}

/** Resolve request auth so multi-account provider overrides are honored. */
async function resolveCodexAuth(authSource: unknown): Promise<ResolvedCodexAuth | undefined> {
	if (isRecord(authSource) && typeof authSource.getProviderAuth === "function") {
		const result = await (authSource as {
			getProviderAuth(providerId: string): Promise<unknown>;
		}).getProviderAuth(PROVIDER_ID);
		if (isRecord(result) && isRecord(result.auth) && typeof result.auth.apiKey === "string") {
			const accessToken = result.auth.apiKey;
			return {
				accessToken,
				accountId:
					getHeader(result.auth.headers, "chatgpt-account-id")
					?? getTokenAccountId(accessToken),
			};
		}
	}

	// Compatibility with older registry/auth-storage facades.
	if (isRecord(authSource) && typeof authSource.getApiKey === "function") {
		const token = await (authSource as {
			getApiKey(providerId: string, options: { includeFallback: boolean }): Promise<unknown>;
		}).getApiKey(PROVIDER_ID, { includeFallback: false });
		if (typeof token === "string") {
			return { accessToken: token, accountId: getTokenAccountId(token) };
		}
	}

	const credential = readStoredProviderCredential(PROVIDER_ID);
	if (!isRecord(credential) || credential.type !== "oauth" || typeof credential.access !== "string") {
		return undefined;
	}
	const storedAccountId = typeof credential.accountId === "string" && credential.accountId.trim()
		? credential.accountId.trim()
		: undefined;
	return {
		accessToken: credential.access,
		accountId: getTokenAccountId(credential.access) ?? storedAccountId,
	};
}

function formatUsagePercent(value?: number): string | undefined {
	if (typeof value !== "number" || !Number.isFinite(value)) return undefined;
	return `${Math.round(100 - value)}%`;
}

export function isOpenAICodexProvider(provider?: string): boolean {
	return provider === PROVIDER_ID;
}

export function formatUsageSummary(
	snapshot: UsageSnapshot | undefined,
	windows: UsageSummaryWindowsConfig,
): string | undefined {
	if (!snapshot) return undefined;

	const primary = formatUsagePercent(snapshot.primary?.usedPercent);
	const secondary = formatUsagePercent(snapshot.secondary?.usedPercent);
	const parts: string[] = [];

	if (windows.primary.enabled && primary) parts.push(`${windows.primary.label} ${primary}`);
	if (windows.secondary.enabled && secondary) parts.push(`${windows.secondary.label} ${secondary}`);

	return parts.length > 0 ? parts.join(" · ") : undefined;
}

export async function fetchOpenAICodexUsage(
	authSource: unknown,
	options?: { timeoutMs?: number },
): Promise<UsageSnapshot | undefined> {
	const auth = await resolveCodexAuth(authSource);
	if (!auth) return undefined;

	const { accessToken, accountId } = auth;
	const controller = new AbortController();
	const timeoutMs = options?.timeoutMs ?? 10_000;
	const timeout = setTimeout(() => controller.abort(), timeoutMs);

	try {
		const headers: Record<string, string> = {
			Authorization: `Bearer ${accessToken}`,
			Accept: "application/json",
		};
		if (accountId) headers["chatgpt-account-id"] = accountId;

		const response = await fetch("https://chatgpt.com/backend-api/wham/usage", {
			headers,
			signal: controller.signal,
		});
		if (!response.ok) {
			throw new Error(`Usage request failed: ${response.status}`);
		}

		const data = (await response.json()) as WhamUsageResponse;
		return { ...parseUsageSnapshot(data), fetchedAt: Date.now() };
	} finally {
		clearTimeout(timeout);
	}
}

export const __testing = {
	decodeJwtPayload,
	getTokenAccountId,
	parseUsageSnapshot,
	resolveCodexAuth,
};
