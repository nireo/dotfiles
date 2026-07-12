import { describe, expect, it } from "vitest";
import discussExtension from "./index.js";

describe("discussExtension", () => {
  it("registers /discuss without a global Alt+D shortcut", () => {
    const commands: string[] = [];
    const shortcuts: string[] = [];
    const events: string[] = [];
    const pi = {
      registerCommand: (name: string) => commands.push(name),
      registerShortcut: (shortcut: string) => shortcuts.push(shortcut),
      on: (event: string) => events.push(event),
    } as never;

    discussExtension(pi);

    expect(commands).toEqual(["discuss"]);
    expect(shortcuts).toEqual([]);
    expect(events).toEqual(["session_shutdown"]);
  });
});
