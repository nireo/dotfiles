import type {
	AuthInteraction,
	AuthPrompt,
	AuthResult,
	Credential,
	OAuthCredential,
	Provider,
} from "@earendil-works/pi-ai";
import { builtinProviders } from "@earendil-works/pi-ai/providers/all";
import type {
	ExtensionAPI,
	ExtensionCommandContext,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { getAgentDir, readStoredCredential } from "@earendil-works/pi-coding-agent";
import { chmodSync, existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export const OPENAI_ACCOUNT_CHANGED_EVENT = "openai-account-changed";

export const OPENAI_ACCOUNT_SLOTS = ["account-1", "account-2"] as const;
export type OpenAIAccountSlot = (typeof OPENAI_ACCOUNT_SLOTS)[number];

const OPENAI_PROVIDER = "openai-codex";
const LEGACY_SECOND_ACCOUNT_PROVIDER = "openai-codex-account-2";
const CONFIG_VERSION = 1;
const STORE_DIR = join(getAgentDir(), "openai-accounts");
const CONFIG_PATH = join(STORE_DIR, "config.json");
const LOGIN_WIDGET_ID = "openai-account-login";
const DEFAULT_ACCOUNT_NAMES: Record<OpenAIAccountSlot, string> = {
	"account-1": "Account 1",
	"account-2": "Account 2",
};
let cachedConfig: OpenAIAccountConfig | undefined;

interface OpenAIAccountConfig {
	version: typeof CONFIG_VERSION;
	names: Record<OpenAIAccountSlot, string>;
	active?: OpenAIAccountSlot;
}

type StoredCredentials = Record<string, Credential>;

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isAccountSlot(value: unknown): value is OpenAIAccountSlot {
	return value === "account-1" || value === "account-2";
}

function defaultConfig(): OpenAIAccountConfig {
	return {
		version: CONFIG_VERSION,
		names: { ...DEFAULT_ACCOUNT_NAMES },
	};
}

export function normalizeOpenAIAccountName(value: string): string {
	const name = value.trim().replace(/\s+/g, " ");
	if (!name) throw new Error("Account name cannot be empty");
	if (name.length > 40) throw new Error("Account name must be 40 characters or fewer");
	if (/[\u0000-\u001f\u007f]/.test(name)) throw new Error("Account name contains invalid characters");
	return name;
}

function loadConfig(): OpenAIAccountConfig {
	if (cachedConfig) return cachedConfig;

	const config = defaultConfig();
	if (existsSync(CONFIG_PATH)) {
		try {
			const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as unknown;
			if (isRecord(parsed) && parsed.version === CONFIG_VERSION && isRecord(parsed.names)) {
				for (const slot of OPENAI_ACCOUNT_SLOTS) {
					const value = parsed.names[slot];
					if (typeof value !== "string") continue;
					try {
						config.names[slot] = normalizeOpenAIAccountName(value);
					} catch {
						// Keep the safe default for malformed local configuration.
					}
				}
				if (isAccountSlot(parsed.active)) config.active = parsed.active;
			}
		} catch {
			// Account names are optional decoration; a broken file must not stop pi.
		}
	}

	cachedConfig = config;
	return config;
}

function writePrivateJson(path: string, value: unknown): void {
	mkdirSync(STORE_DIR, { recursive: true, mode: 0o700 });
	chmodSync(STORE_DIR, 0o700);
	const temporaryPath = `${path}.${process.pid}.${Date.now()}.tmp`;
	writeFileSync(temporaryPath, `${JSON.stringify(value, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
	chmodSync(temporaryPath, 0o600);
	renameSync(temporaryPath, path);
	chmodSync(path, 0o600);
}

function saveConfig(config: OpenAIAccountConfig): void {
	cachedConfig = config;
	writePrivateJson(CONFIG_PATH, config);
}

function updateConfig(update: (config: OpenAIAccountConfig) => void): OpenAIAccountConfig {
	const config = loadConfig();
	update(config);
	saveConfig(config);
	return config;
}

function credentialPath(slot: OpenAIAccountSlot): string {
	return join(STORE_DIR, `${slot}.json`);
}

function readAccountCredential(slot: OpenAIAccountSlot): OAuthCredential | undefined {
	try {
		const parsed = JSON.parse(readFileSync(credentialPath(slot), "utf8")) as unknown;
		if (!isRecord(parsed)) return undefined;
		const credential = parsed[OPENAI_PROVIDER];
		return isRecord(credential) && credential.type === "oauth"
			? (credential as OAuthCredential)
			: undefined;
	} catch {
		return undefined;
	}
}

function writeAccountCredential(slot: OpenAIAccountSlot, credential: OAuthCredential): void {
	const credentials: StoredCredentials = { [OPENAI_PROVIDER]: credential };
	writePrivateJson(credentialPath(slot), credentials);
}

function migrateLegacyCredentials(): void {
	const legacyProviders: Record<OpenAIAccountSlot, string> = {
		"account-1": OPENAI_PROVIDER,
		"account-2": LEGACY_SECOND_ACCOUNT_PROVIDER,
	};
	for (const slot of OPENAI_ACCOUNT_SLOTS) {
		if (existsSync(credentialPath(slot))) continue;
		const credential = readStoredCredential(legacyProviders[slot]);
		if (credential?.type === "oauth") writeAccountCredential(slot, credential);
	}
}

/** Both accounts use Pi's one canonical OpenAI Codex provider and model catalog. */
export function getOpenAIAccountProvider(_slot: OpenAIAccountSlot): string {
	return OPENAI_PROVIDER;
}

/** Return the active account when the selected model is an OpenAI Codex model. */
export function getOpenAIAccountSlot(provider: string | undefined): OpenAIAccountSlot | undefined {
	return provider === OPENAI_PROVIDER ? loadConfig().active : undefined;
}

/** Return the active account's display name for an OpenAI Codex model. */
export function getOpenAIAccountName(provider: string | undefined): string | undefined {
	const slot = getOpenAIAccountSlot(provider);
	return slot ? loadConfig().names[slot] : undefined;
}

function accountNumber(slot: OpenAIAccountSlot): string {
	return slot === "account-1" ? "1" : "2";
}

function accountReference(config: OpenAIAccountConfig, reference: string): OpenAIAccountSlot | undefined {
	const value = reference.trim().toLocaleLowerCase();
	if (value === "1" || value === "account-1" || value === "account 1") return "account-1";
	if (value === "2" || value === "account-2" || value === "account 2") return "account-2";
	return OPENAI_ACCOUNT_SLOTS.find((slot) => config.names[slot].toLocaleLowerCase() === value);
}

function accountStatus(slot: OpenAIAccountSlot): string {
	return readAccountCredential(slot) ? "logged in" : "not logged in";
}

function accountOptions(config: OpenAIAccountConfig): string[] {
	return OPENAI_ACCOUNT_SLOTS.map((slot) => {
		const marker = config.active === slot ? "✓" : " ";
		return `${marker} ${accountNumber(slot)} · ${config.names[slot]} (${accountStatus(slot)})`;
	});
}

async function chooseAccount(
	ctx: ExtensionCommandContext,
	config: OpenAIAccountConfig,
): Promise<OpenAIAccountSlot | undefined> {
	const options = accountOptions(config);
	const selected = await ctx.ui.select("OpenAI account:", options);
	if (!selected) return undefined;
	const index = options.indexOf(selected);
	return index >= 0 ? OPENAI_ACCOUNT_SLOTS[index] : undefined;
}

async function openExternal(pi: ExtensionAPI, url: string): Promise<void> {
	if (process.platform === "darwin") return void (await pi.exec("open", [url]));
	if (process.platform === "win32") return void (await pi.exec("cmd", ["/c", "start", "", url]));
	await pi.exec("xdg-open", [url]);
}

function loginInteraction(pi: ExtensionAPI, ctx: ExtensionCommandContext): AuthInteraction {
	return {
		async prompt(prompt: AuthPrompt): Promise<string> {
			if (prompt.type === "select") {
				const labels = prompt.options.map((option) => option.label);
				const selected = await ctx.ui.select(prompt.message, labels);
				const id = prompt.options.find((option) => option.label === selected)?.id;
				if (!id) throw new Error("Login cancelled");
				return id;
			}
			const value = await ctx.ui.input(prompt.message, prompt.placeholder);
			if (value === undefined) throw new Error("Login cancelled");
			return value;
		},
		notify(event): void {
			if (event.type === "auth_url") {
				ctx.ui.setWidget(LOGIN_WIDGET_ID, [
					"Complete the OpenAI login in your browser.",
					...(event.instructions ? [event.instructions] : []),
					event.url,
				]);
				void openExternal(pi, event.url).catch(() => {});
			} else if (event.type === "device_code") {
				ctx.ui.setWidget(LOGIN_WIDGET_ID, [
					`OpenAI device code: ${event.userCode}`,
					`Open: ${event.verificationUri}`,
				]);
				void openExternal(pi, event.verificationUri).catch(() => {});
			} else if (event.type === "progress") {
				ctx.ui.setStatus(LOGIN_WIDGET_ID, event.message);
			} else if (event.type === "info") {
				ctx.ui.notify(event.message, "info");
			}
		},
	};
}

async function resolveCredential(
	base: Provider,
	slot: OpenAIAccountSlot,
): Promise<AuthResult | undefined> {
	const oauth = base.auth.oauth;
	let credential = readAccountCredential(slot);
	if (!oauth || !credential) return undefined;
	if (credential.expires <= Date.now() + 5 * 60_000) {
		credential = await oauth.refresh(credential, new AbortController().signal);
		writeAccountCredential(slot, credential);
	}
	return { auth: await oauth.toAuth(credential), source: loadConfig().names[slot] };
}

function accountProvider(base: Provider, getAuth: () => AuthResult | undefined): Provider {
	const oauth = base.auth.oauth;
	return {
		...base,
		auth: {
			apiKey: {
				name: "OpenAI account managed by /account",
				async check() {
					return getAuth() ? { type: "api_key", source: "OpenAI account" } : undefined;
				},
				async resolve() {
					return getAuth();
				},
			},
			...(oauth ? {
				oauth: {
					...oauth,
					// A legacy credential may still exist under openai-codex in the
					// global auth store. Keep its type resolvable, but route requests
					// through the independently selected account credential.
					async toAuth(credential: OAuthCredential) {
						return getAuth()?.auth ?? oauth.toAuth(credential);
					},
				},
			} : {}),
		},
	};
}

export default async function (pi: ExtensionAPI): Promise<void> {
	migrateLegacyCredentials();
	const base = builtinProviders().find((provider) => provider.id === OPENAI_PROVIDER);
	if (!base) return;

	let activeAuth: AuthResult | undefined;
	const initialSlot = loadConfig().active;
	if (initialSlot) {
		try {
			activeAuth = await resolveCredential(base, initialSlot);
		} catch {
			// Report refresh failures once a UI context is available.
		}
	}
	pi.registerProvider(accountProvider(base, () => activeAuth));

	const activateAccount = async (
		slot: OpenAIAccountSlot,
		ctx: ExtensionContext,
		notify: boolean,
	): Promise<boolean> => {
		try {
			const wasConfigured = activeAuth !== undefined;
			const switched = loadConfig().active !== slot;
			const auth = await resolveCredential(base, slot);
			if (!auth) {
				if (notify) ctx.ui.notify(`Log in first with /account login ${accountNumber(slot)}`, "warning");
				return false;
			}
			activeAuth = auth;
			if (switched) updateConfig((config) => { config.active = slot; });
			if (!wasConfigured) {
				await ctx.modelRegistry.refresh({ allowNetwork: false, providers: [OPENAI_PROVIDER] });
			}
			if (switched || !wasConfigured) pi.events.emit(OPENAI_ACCOUNT_CHANGED_EVENT, slot);
			if (notify) ctx.ui.notify(`Using OpenAI account: ${loadConfig().names[slot]}`, "info");
			return true;
		} catch (error) {
			if (notify) ctx.ui.notify(`Could not select account: ${error instanceof Error ? error.message : String(error)}`, "error");
			return false;
		}
	};

	const loginAccount = async (slot: OpenAIAccountSlot, ctx: ExtensionCommandContext): Promise<void> => {
		const oauth = base.auth.oauth;
		if (!oauth) throw new Error("OpenAI OAuth is unavailable");
		try {
			const interaction = loginInteraction(pi, ctx);
			const credential = await oauth.login({
				...interaction,
				signal: new AbortController().signal,
			});
			writeAccountCredential(slot, credential);
			await activateAccount(slot, ctx, false);
			ctx.ui.notify(`Logged in as ${loadConfig().names[slot]}`, "info");
		} finally {
			ctx.ui.setWidget(LOGIN_WIDGET_ID, undefined);
			ctx.ui.setStatus(LOGIN_WIDGET_ID, undefined);
		}
	};

	const renameAccount = async (
		reference: string,
		requestedName: string,
		ctx: ExtensionCommandContext,
	): Promise<void> => {
		let config = loadConfig();
		let slot = accountReference(config, reference);
		if (!slot) slot = await chooseAccount(ctx, config);
		if (!slot) return;
		const enteredName = requestedName || await ctx.ui.input(`Name OpenAI account ${accountNumber(slot)}:`, config.names[slot]);
		if (enteredName === undefined) return;
		const name = normalizeOpenAIAccountName(enteredName);
		if (OPENAI_ACCOUNT_SLOTS.some((candidate) => candidate !== slot && config.names[candidate].toLocaleLowerCase() === name.toLocaleLowerCase())) {
			ctx.ui.notify(`An account named "${name}" already exists`, "error");
			return;
		}
		config = updateConfig((latest) => { latest.names[slot!] = name; });
		pi.events.emit(OPENAI_ACCOUNT_CHANGED_EVENT, slot);
		ctx.ui.notify(`Renamed OpenAI account ${accountNumber(slot)} to ${config.names[slot]}`, "info");
	};

	const handleCommand = async (args: string, ctx: ExtensionCommandContext): Promise<void> => {
		const input = args.trim();
		const config = loadConfig();
		if (!input) {
			const slot = await chooseAccount(ctx, config);
			if (slot) await activateAccount(slot, ctx, true);
			return;
		}
		const [action = "", ...rest] = input.split(/\s+/u);
		const reference = rest.join(" ");
		switch (action.toLocaleLowerCase()) {
			case "use":
			case "select":
			case "switch": {
				const slot = accountReference(config, reference) ?? (!reference ? await chooseAccount(ctx, config) : undefined);
				if (!slot) return void ctx.ui.notify(`Unknown OpenAI account: ${reference}`, "error");
				await activateAccount(slot, ctx, true);
				return;
			}
			case "rename": {
				const [accountRef = "", ...nameParts] = rest;
				await renameAccount(accountRef, nameParts.join(" "), ctx);
				return;
			}
			case "login": {
				const slot = accountReference(config, reference);
				if (!slot) return void ctx.ui.notify("Choose account 1 or 2, for example: /account login 2", "error");
				await loginAccount(slot, ctx);
				return;
			}
			case "current":
				ctx.ui.notify(config.active ? `OpenAI account ${accountNumber(config.active)}: ${config.names[config.active]}` : "No OpenAI account selected", "info");
				return;
			case "list":
				ctx.ui.notify(OPENAI_ACCOUNT_SLOTS.map((slot) => `${config.active === slot ? "✓ " : ""}${accountNumber(slot)}: ${config.names[slot]} (${accountStatus(slot)})`).join("  "), "info");
				return;
			default: {
				const slot = accountReference(config, input);
				if (!slot) return void ctx.ui.notify("Usage: /account [1|2|use|rename|login|list|current]", "error");
				await activateAccount(slot, ctx, true);
			}
		}
	};

	const command = {
		description: "Select or manage the two OpenAI Codex accounts",
		getArgumentCompletions: (prefix: string) => ["1", "2", "use", "rename", "login", "list", "current"]
			.filter((value) => value.startsWith(prefix.toLocaleLowerCase()))
			.map((value) => ({ value, label: value })),
		handler: async (args: string, ctx: ExtensionCommandContext) => {
			try {
				await handleCommand(args, ctx);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
			}
		},
	};
	pi.registerCommand("account", command);
	pi.registerCommand("openai-account", command);

	pi.on("session_start", async (_event, ctx) => {
		const slot = loadConfig().active;
		if (slot) await activateAccount(slot, ctx, false);
		pi.events.emit(OPENAI_ACCOUNT_CHANGED_EVENT, slot);
	});

	pi.on("turn_start", async (_event, ctx) => {
		const slot = loadConfig().active;
		if (!slot || ctx.model?.provider !== OPENAI_PROVIDER) return;
		await activateAccount(slot, ctx, false);
	});
}

export const __testing = {
	defaultConfig,
	getOpenAIAccountName,
	getOpenAIAccountProvider,
	getOpenAIAccountSlot,
	normalizeOpenAIAccountName,
};
