import {
	AuthStorage,
	FooterComponent,
	getAgentDir,
	type ExtensionAPI,
	type ExtensionCommandContext,
	type ExtensionContext,
	type OAuthCredential,
} from "@earendil-works/pi-coding-agent";
import { randomUUID } from "node:crypto";
import {
	chmodSync,
	existsSync,
	mkdirSync,
	readFileSync,
	renameSync,
	rmSync,
	statSync,
	writeFileSync,
} from "node:fs";
import { join } from "node:path";

const PROVIDER = "openai-codex";
const STATUS_ID = "openai-account";
const LOGIN_WIDGET_ID = "openai-account-login";
const STORE_DIR = join(getAgentDir(), "openai-accounts");
const CONFIG_PATH = join(STORE_DIR, "config.json");
const LOCK_PATH = join(STORE_DIR, ".config.lock");
const CONFIG_VERSION = 1;
const LOCK_STALE_MS = 30_000;
const ACCOUNT_ID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

interface AccountRecord {
	id: string;
	label: string;
	createdAt: string;
}

interface AccountConfig {
	version: 1;
	activeId?: string;
	accounts: AccountRecord[];
}

function emptyConfig(): AccountConfig {
	return { version: CONFIG_VERSION, accounts: [] };
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function loadConfig(): AccountConfig {
	if (!existsSync(CONFIG_PATH)) return emptyConfig();

	const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as unknown;
	if (!isRecord(parsed) || parsed.version !== CONFIG_VERSION || !Array.isArray(parsed.accounts)) {
		throw new Error(`Invalid OpenAI account config: ${CONFIG_PATH}`);
	}

	const accounts: AccountRecord[] = [];
	for (const value of parsed.accounts) {
		if (
			!isRecord(value) ||
			typeof value.id !== "string" ||
			!ACCOUNT_ID_PATTERN.test(value.id) ||
			typeof value.label !== "string" ||
			typeof value.createdAt !== "string"
		) {
			throw new Error(`Invalid account entry in ${CONFIG_PATH}`);
		}
		accounts.push({ id: value.id, label: value.label, createdAt: value.createdAt });
	}

	const activeId = typeof parsed.activeId === "string" ? parsed.activeId : undefined;
	return { version: CONFIG_VERSION, activeId, accounts };
}

function ensureStoreDirectory(): void {
	mkdirSync(STORE_DIR, { recursive: true, mode: 0o700 });
	chmodSync(STORE_DIR, 0o700);
}

function sleepSync(milliseconds: number): void {
	Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, milliseconds);
}

function withStoreLock<T>(operation: () => T): T {
	ensureStoreDirectory();
	for (let attempt = 0; attempt < 100; attempt++) {
		let lockInode: number;
		try {
			mkdirSync(LOCK_PATH, { mode: 0o700 });
			lockInode = statSync(LOCK_PATH).ino;
		} catch (error) {
			const code = isRecord(error) && typeof error.code === "string" ? error.code : undefined;
			if (code !== "EEXIST") throw error;
			try {
				if (Date.now() - statSync(LOCK_PATH).mtimeMs > LOCK_STALE_MS) {
					rmSync(LOCK_PATH, { recursive: true, force: true });
					continue;
				}
			} catch {
				continue;
			}
			sleepSync(20);
			continue;
		}

		try {
			return operation();
		} finally {
			try {
				// Do not delete a replacement lock if this lock was reaped as stale.
				if (statSync(LOCK_PATH).ino === lockInode) {
					rmSync(LOCK_PATH, { recursive: true, force: true });
				}
			} catch {
				// The lock was already removed.
			}
		}
	}
	throw new Error("Timed out waiting for the OpenAI account store");
}

function saveConfigUnlocked(config: AccountConfig): void {
	ensureStoreDirectory();
	const temporaryPath = `${CONFIG_PATH}.${process.pid}.${Date.now()}.tmp`;
	writeFileSync(temporaryPath, `${JSON.stringify(config, null, 2)}\n`, {
		encoding: "utf8",
		mode: 0o600,
	});
	chmodSync(temporaryPath, 0o600);
	renameSync(temporaryPath, CONFIG_PATH);
	chmodSync(CONFIG_PATH, 0o600);
}

function updateConfig(update: (config: AccountConfig) => void): AccountConfig {
	return withStoreLock(() => {
		const config = loadConfig();
		update(config);
		saveConfigUnlocked(config);
		return config;
	});
}

function accountDir(accountId: string): string {
	return join(STORE_DIR, accountId);
}

function accountAuthPath(accountId: string): string {
	return join(accountDir(accountId), "auth.json");
}

function createAccountStorage(accountId: string): AuthStorage {
	const directory = accountDir(accountId);
	mkdirSync(directory, { recursive: true, mode: 0o700 });
	chmodSync(directory, 0o700);
	return AuthStorage.create(accountAuthPath(accountId));
}

function openAccountStorage(accountId: string): AuthStorage {
	const path = accountAuthPath(accountId);
	if (!existsSync(path)) throw new Error("The saved credentials for this account are missing");
	return AuthStorage.create(path);
}

function normalizeLabel(value: string): string {
	const label = value.trim().replace(/\s+/g, " ");
	if (!label) throw new Error("Account name cannot be empty");
	if (label.length > 40) throw new Error("Account name must be 40 characters or fewer");
	if (/[\u0000-\u001f\u007f]/.test(label)) throw new Error("Account name contains invalid characters");
	return label;
}

function findAccount(config: AccountConfig, reference: string): AccountRecord | undefined {
	const normalized = reference.trim().toLocaleLowerCase();
	return config.accounts.find(
		(account) => account.id === reference || account.label.toLocaleLowerCase() === normalized,
	);
}

function assertUniqueLabel(config: AccountConfig, label: string): void {
	if (config.accounts.some((account) => account.label.toLocaleLowerCase() === label.toLocaleLowerCase())) {
		throw new Error(`An account named "${label}" already exists`);
	}
}

function getOAuthCredential(storage: AuthStorage): OAuthCredential | undefined {
	const credential = storage.get(PROVIDER);
	return credential?.type === "oauth" ? credential : undefined;
}

function getCredentialAccountId(credential: OAuthCredential): string | undefined {
	return typeof credential.accountId === "string" ? credential.accountId : undefined;
}

function findDuplicateCredential(config: AccountConfig, credential: OAuthCredential): AccountRecord | undefined {
	const candidateId = getCredentialAccountId(credential);
	if (!candidateId) return undefined;

	for (const account of config.accounts) {
		try {
			const existing = getOAuthCredential(openAccountStorage(account.id));
			if (existing && getCredentialAccountId(existing) === candidateId) return account;
		} catch {
			// A broken profile should not prevent adding a replacement account.
		}
	}
	return undefined;
}

function statusText(label?: string): string {
	return label ? `OpenAI: ${label}` : "OpenAI: not set";
}

async function openExternal(pi: ExtensionAPI, url: string): Promise<void> {
	if (process.platform === "darwin") {
		await pi.exec("open", [url]);
		return;
	}
	if (process.platform === "win32") {
		await pi.exec("cmd", ["/c", "start", "", url]);
		return;
	}
	await pi.exec("xdg-open", [url]);
}

export default async function (pi: ExtensionAPI) {
	let activeId: string | undefined;
	let activeLabel: string | undefined;
	let mainAuthStorage: AuthStorage | undefined;
	let providerOverrideRegistered = false;

	// Provider registration happens before initial model resolution, unlike
	// session_start. This keeps openai-codex available even though credentials
	// live in isolated per-account stores rather than the global auth.json.
	try {
		const config = loadConfig();
		const account =
			config.accounts.find((candidate) => candidate.id === config.activeId) ?? config.accounts[0];
		if (account) {
			const accessToken = await openAccountStorage(account.id).getApiKey(PROVIDER);
			if (accessToken) {
				pi.registerProvider(PROVIDER, { apiKey: accessToken });
				providerOverrideRegistered = true;
				activeId = account.id;
				activeLabel = account.label;
			}
		}
	} catch {
		// session_start reports profile errors once UI is available.
	}

	let currentModel: ExtensionContext["model"];
	let footerSessionManager: ExtensionContext["sessionManager"] | undefined;
	let footerAccountId: string | undefined;

	const installAccountFooter = (ctx: ExtensionContext, force = false): void => {
		// Clear the old setStatus entry used by earlier versions of this extension.
		ctx.ui.setStatus(STATUS_ID, undefined);
		currentModel = ctx.model ?? currentModel;
		if (ctx.mode !== "tui") return;
		if (!force && footerSessionManager === ctx.sessionManager && footerAccountId === activeId) return;

		footerSessionManager = ctx.sessionManager;
		footerAccountId = activeId;
		ctx.ui.setFooter((tui, _theme, footerData) => {
			const sessionFacade = {
				get state() {
					return { model: currentModel, thinkingLevel: pi.getThinkingLevel() };
				},
				sessionManager: ctx.sessionManager,
				modelRegistry: ctx.modelRegistry,
				getContextUsage: () => ctx.getContextUsage(),
			};
			const baseFooter = new FooterComponent(sessionFacade as never, footerData);
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose() {
					unsubscribe();
					baseFooter.dispose();
				},
				invalidate() {
					baseFooter.invalidate();
				},
				render(width: number): string[] {
					const lines = baseFooter.render(width);
					if (!activeLabel || !lines[1]) return lines;

					const indicator = `openai (${activeLabel.toLocaleLowerCase()})`;
					const needed = Array.from(indicator).length + 1;
					const paddingMatches = Array.from(lines[1].matchAll(/ {2,}/g));
					const padding = paddingMatches.sort((a, b) => b[0].length - a[0].length)[0];
					if (!padding || padding.index === undefined || padding[0].length < needed) return lines;

					const remainingPadding = " ".repeat(padding[0].length - needed);
					lines[1] =
						lines[1].slice(0, padding.index) +
						` ${indicator}${remainingPadding}` +
						lines[1].slice(padding.index + padding[0].length);
					return lines;
				},
			};
		});
	};

	const activate = async (account: AccountRecord, ctx: ExtensionContext): Promise<void> => {
		if (!mainAuthStorage) mainAuthStorage = ctx.modelRegistry.authStorage;

		const profileStorage = openAccountStorage(account.id);
		const accessToken = await profileStorage.getApiKey(PROVIDER);
		if (!accessToken) throw new Error(`Could not authenticate "${account.label}"; add it again to re-login`);

		pi.registerProvider(PROVIDER, { apiKey: accessToken });
		providerOverrideRegistered = true;
		mainAuthStorage.setRuntimeApiKey(PROVIDER, accessToken);
		activeId = account.id;
		activeLabel = account.label;
		installAccountFooter(ctx);
	};

	const activateConfiguredAccount = async (ctx: ExtensionContext): Promise<void> => {
		const config = loadConfig();
		const account = config.accounts.find((candidate) => candidate.id === activeId);
		if (!account) {
			mainAuthStorage?.removeRuntimeApiKey(PROVIDER);
			if (providerOverrideRegistered) {
				pi.unregisterProvider(PROVIDER);
				providerOverrideRegistered = false;
			}
			activeId = undefined;
			activeLabel = undefined;
			installAccountFooter(ctx);
			return;
		}
		await activate(account, ctx);
	};

	const importExistingAccount = (ctx: ExtensionContext): AccountConfig => {
		const credential = getOAuthCredential(ctx.modelRegistry.authStorage);
		if (!credential) return loadConfig();

		const config = withStoreLock(() => {
			const latest = loadConfig();
			const duplicate = findDuplicateCredential(latest, credential);
			if (duplicate) {
				openAccountStorage(duplicate.id).set(PROVIDER, credential);
				latest.activeId = duplicate.id;
				saveConfigUnlocked(latest);
				return latest;
			}

			const baseLabel = latest.accounts.length === 0 ? "Default" : "Imported";
			let label = baseLabel;
			let suffix = 2;
			while (latest.accounts.some((account) => account.label.toLocaleLowerCase() === label.toLocaleLowerCase())) {
				label = `${baseLabel} ${suffix++}`;
			}
			const account: AccountRecord = {
				id: randomUUID(),
				label,
				createdAt: new Date().toISOString(),
			};
			createAccountStorage(account.id).set(PROVIDER, credential);
			latest.accounts.push(account);
			latest.activeId = account.id;
			saveConfigUnlocked(latest);
			return latest;
		});

		// Once safely copied, remove the global credential so a missing runtime
		// override can never silently fall back to a different OpenAI account.
		ctx.modelRegistry.authStorage.remove(PROVIDER);
		return config;
	};

	const oauthCallbacks = (ctx: ExtensionCommandContext) => ({
		onAuth: (info: { url: string; instructions?: string }) => {
			ctx.ui.setWidget(LOGIN_WIDGET_ID, [
				"Complete the OpenAI login in your browser.",
				...(info.instructions ? [info.instructions] : []),
				info.url,
			]);
			void openExternal(pi, info.url).catch(() => {
				ctx.ui.notify("Could not open the browser automatically; use the URL shown above.", "warning");
			});
		},
		onDeviceCode: (info: { userCode: string; verificationUri: string }) => {
			ctx.ui.setWidget(LOGIN_WIDGET_ID, [
				`OpenAI device code: ${info.userCode}`,
				`Open: ${info.verificationUri}`,
			]);
			void openExternal(pi, info.verificationUri).catch(() => {
				ctx.ui.notify("Could not open the browser automatically; use the URL shown above.", "warning");
			});
		},
		onPrompt: async (prompt: { message: string; placeholder?: string }) => {
			const value = await ctx.ui.input(prompt.message, prompt.placeholder);
			if (value === undefined) throw new Error("Login cancelled");
			return value;
		},
		onProgress: (message: string) => ctx.ui.setStatus(STATUS_ID, `OpenAI login: ${message}`),
		onSelect: async (prompt: { message: string; options: Array<{ id: string; label: string }> }) => {
			const labels = prompt.options.map((option) => option.label);
			const selected = await ctx.ui.select(prompt.message, labels);
			return prompt.options.find((option) => option.label === selected)?.id;
		},
	});

	const addAccount = async (requestedLabel: string, ctx: ExtensionCommandContext): Promise<void> => {
		const enteredLabel = requestedLabel || (await ctx.ui.input("Name this OpenAI account:", "Work or Personal"));
		if (enteredLabel === undefined) return;
		const label = normalizeLabel(enteredLabel);
		assertUniqueLabel(loadConfig(), label);

		const account: AccountRecord = {
			id: randomUUID(),
			label,
			createdAt: new Date().toISOString(),
		};
		const profileStorage = createAccountStorage(account.id);

		try {
			await profileStorage.login(PROVIDER, oauthCallbacks(ctx));
			const credential = getOAuthCredential(profileStorage);
			if (!credential) throw new Error("OpenAI login did not return OAuth credentials");

			withStoreLock(() => {
				const config = loadConfig();
				assertUniqueLabel(config, label);
				const duplicate = findDuplicateCredential(config, credential);
				if (duplicate) throw new Error(`That OpenAI login is already saved as "${duplicate.label}"`);
				config.accounts.push(account);
				config.activeId = account.id;
				saveConfigUnlocked(config);
			});
			await activate(account, ctx);
			ctx.ui.notify(`Using OpenAI account: ${label}`, "info");
		} catch (error) {
			rmSync(accountDir(account.id), { recursive: true, force: true });
			installAccountFooter(ctx);
			throw error;
		} finally {
			ctx.ui.setWidget(LOGIN_WIDGET_ID, undefined);
		}
	};

	const switchAccount = async (reference: string, ctx: ExtensionCommandContext): Promise<void> => {
		const config = loadConfig();
		const account = findAccount(config, reference);
		if (!account) throw new Error(`Unknown OpenAI account: ${reference}`);

		await activate(account, ctx);
		updateConfig((latest) => {
			if (!latest.accounts.some((candidate) => candidate.id === account.id)) {
				throw new Error(`OpenAI account was removed while switching: ${account.label}`);
			}
			latest.activeId = account.id;
		});
		ctx.ui.notify(`Using OpenAI account: ${account.label}`, "info");
	};

	const chooseAndSwitch = async (ctx: ExtensionCommandContext): Promise<void> => {
		const config = loadConfig();
		const options = config.accounts.map((account) =>
			account.id === activeId ? `✓ ${account.label}` : `  ${account.label}`,
		);
		options.push("＋ Add account…");
		if (config.accounts.length > 0) options.push("− Remove account…");

		const selected = await ctx.ui.select("OpenAI account:", options);
		if (!selected) return;
		if (selected === "＋ Add account…") {
			await addAccount("", ctx);
			return;
		}
		if (selected === "− Remove account…") {
			await chooseAndRemove(ctx);
			return;
		}

		const index = options.indexOf(selected);
		const account = config.accounts[index];
		if (account && account.id !== activeId) await switchAccount(account.id, ctx);
	};

	const removeAccount = async (reference: string, ctx: ExtensionCommandContext): Promise<void> => {
		const config = loadConfig();
		const account = findAccount(config, reference);
		if (!account) throw new Error(`Unknown OpenAI account: ${reference}`);

		const confirmed = await ctx.ui.confirm("Remove OpenAI account?", `Remove "${account.label}" from pi?`);
		if (!confirmed) return;

		const removedActive = activeId === account.id;
		const updatedConfig = withStoreLock(() => {
			const latest = loadConfig();
			if (!latest.accounts.some((candidate) => candidate.id === account.id)) {
				throw new Error(`OpenAI account was already removed: ${account.label}`);
			}
			latest.accounts = latest.accounts.filter((candidate) => candidate.id !== account.id);
			if (latest.activeId === account.id) latest.activeId = latest.accounts[0]?.id;
			saveConfigUnlocked(latest);
			return latest;
		});
		rmSync(accountDir(account.id), { recursive: true, force: true });

		if (removedActive) {
			activeId = updatedConfig.activeId;
			if (activeId) {
				await activateConfiguredAccount(ctx);
			} else {
				mainAuthStorage?.removeRuntimeApiKey(PROVIDER);
				if (providerOverrideRegistered) {
					pi.unregisterProvider(PROVIDER);
					providerOverrideRegistered = false;
				}
				activeLabel = undefined;
				installAccountFooter(ctx);
			}
		}
		ctx.ui.notify(`Removed OpenAI account: ${account.label}`, "info");
	};

	const chooseAndRemove = async (ctx: ExtensionCommandContext): Promise<void> => {
		const config = loadConfig();
		if (config.accounts.length === 0) {
			ctx.ui.notify("No OpenAI accounts are saved.", "info");
			return;
		}
		const selected = await ctx.ui.select(
			"Remove OpenAI account:",
			config.accounts.map((account) => account.label),
		);
		if (selected) await removeAccount(selected, ctx);
	};

	pi.registerCommand("account", {
		description: "Switch or manage OpenAI accounts",
		getArgumentCompletions: (prefix) => {
			try {
				const commands = ["add", "current", "list", "remove", "use"];
				const accounts = loadConfig().accounts.map((account) => account.label);
				return [...commands, ...accounts]
					.filter((value) => value.toLocaleLowerCase().startsWith(prefix.toLocaleLowerCase()))
					.map((value) => ({ value, label: value }));
			} catch {
				return null;
			}
		},
		handler: async (args, ctx) => {
			try {
				const input = args.trim();
				if (!input) {
					await chooseAndSwitch(ctx);
					return;
				}

				const [action = "", ...rest] = input.split(/\s+/);
				const reference = rest.join(" ");
				switch (action.toLocaleLowerCase()) {
					case "add":
						await addAccount(reference, ctx);
						return;
					case "current":
						ctx.ui.notify(statusText(activeLabel), "info");
						return;
					case "list": {
						const config = loadConfig();
						const summary = config.accounts
							.map((account) => `${account.id === activeId ? "✓" : "•"} ${account.label}`)
							.join("  ");
						ctx.ui.notify(summary || "No OpenAI accounts are saved.", "info");
						return;
					}
					case "remove":
						if (reference) await removeAccount(reference, ctx);
						else await chooseAndRemove(ctx);
						return;
					case "use":
						if (!reference) throw new Error("Usage: /account use <name>");
						await switchAccount(reference, ctx);
						return;
					default:
						await switchAccount(input, ctx);
				}
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
			}
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		mainAuthStorage = ctx.modelRegistry.authStorage;
		try {
			const config = importExistingAccount(ctx);
			activeId = config.accounts.some((account) => account.id === config.activeId)
				? config.activeId
				: config.accounts[0]?.id;
			if (activeId && activeId !== config.activeId) {
				updateConfig((latest) => {
					if (latest.accounts.some((account) => account.id === activeId)) latest.activeId = activeId;
				});
			}
			await activateConfiguredAccount(ctx);
		} catch (error) {
			mainAuthStorage.removeRuntimeApiKey(PROVIDER);
			if (providerOverrideRegistered) {
				pi.unregisterProvider(PROVIDER);
				providerOverrideRegistered = false;
			}
			activeId = undefined;
			activeLabel = undefined;
			installAccountFooter(ctx);
			ctx.ui.notify(
				`OpenAI account switcher: ${error instanceof Error ? error.message : String(error)}`,
				"error",
			);
		}
	});

	pi.on("model_select", (event, ctx) => {
		currentModel = event.model;
		installAccountFooter(ctx, true);
	});

	pi.on("turn_start", async (_event, ctx) => {
		if (!activeId) return;
		try {
			await activateConfiguredAccount(ctx);
		} catch (error) {
			mainAuthStorage?.removeRuntimeApiKey(PROVIDER);
			if (providerOverrideRegistered) {
				pi.unregisterProvider(PROVIDER);
				providerOverrideRegistered = false;
			}
			ctx.ui.notify(
				`OpenAI account refresh failed: ${error instanceof Error ? error.message : String(error)}`,
				"error",
			);
		}
	});

	pi.on("session_shutdown", (_event, ctx) => {
		mainAuthStorage?.removeRuntimeApiKey(PROVIDER);
		mainAuthStorage = undefined;
		footerSessionManager = undefined;
		footerAccountId = undefined;
		ctx.ui.setStatus(STATUS_ID, undefined);
		ctx.ui.setFooter(undefined);
	});
}
