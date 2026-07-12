import type { ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { Editor, type EditorTheme, type TUI, Key, matchesKey, sliceByColumn, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { DiffRow } from "./diff.js";
import type { ReviewData, ReviewFile } from "./git.js";
import type { Annotation, AnnotationIntent, AnnotationSide } from "./prompt.js";

interface EditTarget {
  fileIndex: number;
  side: AnnotationSide;
  line: number | null;
  intent: AnnotationIntent;
}

function pad(text: string, width: number): string {
  const clipped = truncateToWidth(text, Math.max(1, width), "…", false);
  return clipped + " ".repeat(Math.max(0, width - visibleWidth(clipped)));
}

function renderPane(theme: Theme, title: string, focused: boolean, width: number, height: number, content: string[]): string[] {
  const innerWidth = Math.max(1, width - 2);
  const innerHeight = Math.max(1, height - 2);
  const color = focused ? "accent" : "border";
  const heading = truncateToWidth(` ${focused ? "▶ " : ""}${title} `, Math.max(1, innerWidth - 2), "", false);
  const topPadding = Math.max(0, innerWidth - visibleWidth(heading));
  const top = theme.fg(color, `┌${heading}${"─".repeat(topPadding)}┐`);
  const body = Array.from({ length: innerHeight }, (_, index) => `${theme.fg(color, "│")}${pad(content[index] ?? "", innerWidth)}${theme.fg(color, "│")}`);
  return [top, ...body, theme.fg(color, `└${"─".repeat(innerWidth)}┘`)];
}

function renderFrame(theme: Theme, width: number, height: number, title: string, content: string[]): string[] {
  const innerWidth = Math.max(1, width - 2);
  const innerHeight = Math.max(1, height - 2);
  const heading = truncateToWidth(` ${title} `, Math.max(1, innerWidth - 2), "", false);
  const top = theme.fg("accent", `┌${heading}${"─".repeat(Math.max(0, innerWidth - visibleWidth(heading)))}┐`);
  const body = Array.from({ length: innerHeight }, (_, index) => `${theme.fg("accent", "│")}${pad(content[index] ?? "", innerWidth)}${theme.fg("accent", "│")}`);
  return [top, ...body, theme.fg("accent", `└${"─".repeat(innerWidth)}┘`)];
}

export function renderCenteredOverlay(baseLines: string[], overlayLines: string[], width: number): string[] {
  const overlayWidth = Math.min(width, Math.max(...overlayLines.map((line) => visibleWidth(line))));
  const overlayHeight = Math.min(baseLines.length, overlayLines.length);
  const left = Math.max(0, Math.floor((width - overlayWidth) / 2));
  const top = Math.max(0, Math.floor((baseLines.length - overlayHeight) / 2));
  const result = [...baseLines];

  for (let index = 0; index < overlayHeight; index += 1) {
    const row = top + index;
    const base = result[row] ?? "";
    const overlay = pad(overlayLines[index] ?? "", overlayWidth);
    const prefix = sliceByColumn(base, 0, left);
    const suffix = sliceByColumn(base, left + overlayWidth, Math.max(0, width - left - overlayWidth));
    result[row] = `${prefix}${overlay}${suffix}`;
  }

  return result;
}

function annotationId(filePath: string, side: AnnotationSide, line: number | null): string {
  return `${filePath}\u001f${side}\u001f${line ?? "file"}`;
}

function sideForRow(row: DiffRow): Exclude<AnnotationSide, "file"> | null {
  if (row.kind === "added") return "added";
  if (row.kind === "deleted") return "deleted";
  return null;
}

function lineForRow(row: DiffRow): number | null {
  return row.kind === "added" ? row.newLine : row.kind === "deleted" ? row.oldLine : null;
}

export function getHunkStarts(rows: DiffRow[]): number[] {
  const starts: number[] = [];
  let previousWasChange = false;
  rows.forEach((row, index) => {
    if (row.kind === "context") {
      previousWasChange = false;
    } else if (!previousWasChange) {
      starts.push(index);
      previousWasChange = true;
    }
  });
  return starts;
}

class DiscussionReviewApp {
  focused = false;

  private fileIndex = 0;
  private selectedRow = -1;
  private focus: "files" | "diff" = "files";
  private fileScroll = 0;
  private diffScroll = 0;
  private annotations: Annotation[] = [];
  private editTarget: EditTarget | null = null;
  private message: string | null = null;
  private readonly editor: Editor;

  constructor(
    private readonly tui: TUI,
    private readonly theme: Theme,
    private readonly done: (value: Annotation[] | null) => void,
    private readonly data: ReviewData,
  ) {
    const editorTheme: EditorTheme = {
      borderColor: (text) => this.theme.fg("accent", text),
      selectList: {
        selectedPrefix: (text) => this.theme.fg("accent", text),
        selectedText: (text) => this.theme.fg("accent", text),
        description: (text) => this.theme.fg("muted", text),
        scrollInfo: (text) => this.theme.fg("dim", text),
        noMatch: (text) => this.theme.fg("warning", text),
      },
    };
    this.editor = new Editor(this.tui, editorTheme);
    this.editor.disableSubmit = true;
    this.selectFirstChange();
  }

  invalidate(): void {}

  private requestRender(): void {
    this.tui.requestRender();
  }

  private get activeFile(): ReviewFile {
    return this.data.files[this.fileIndex]!;
  }

  private changedRowIndexes(file = this.activeFile): number[] {
    return file.rows.flatMap((row, index) => row.kind === "context" ? [] : [index]);
  }

  private hunkStarts(file = this.activeFile): number[] {
    return getHunkStarts(file.rows);
  }

  private selectFirstChange(): void {
    this.selectedRow = this.changedRowIndexes()[0] ?? -1;
    this.diffScroll = 0;
  }

  private annotationFor(file: ReviewFile, side: AnnotationSide, line: number | null): Annotation | undefined {
    return this.annotations.find((annotation) => annotation.id === annotationId(file.path, side, line));
  }

  private moveFile(delta: number): void {
    this.fileIndex = Math.max(0, Math.min(this.data.files.length - 1, this.fileIndex + delta));
    this.fileScroll = Math.max(0, this.fileIndex - 2);
    this.selectFirstChange();
    this.message = null;
  }

  private moveDiff(delta: number): void {
    const rows = this.changedRowIndexes();
    if (rows.length === 0) {
      this.message = "This file has no line-level changes; use F or D for a file note.";
      return;
    }
    const current = Math.max(0, rows.indexOf(this.selectedRow));
    const next = Math.max(0, Math.min(rows.length - 1, current + delta));
    this.selectedRow = rows[next]!;
    this.message = null;
  }

  private jumpHunk(delta: -1 | 1): void {
    const starts = this.hunkStarts();
    if (starts.length === 0) {
      this.message = "This file has no changed hunks.";
      return;
    }

    const next = delta > 0
      ? starts.find((start) => start > this.selectedRow) ?? starts[starts.length - 1]!
      : [...starts].reverse().find((start) => start < this.selectedRow) ?? starts[0]!;
    this.selectedRow = next;
    this.focus = "diff";
    this.message = null;
  }

  private openEditor(intent: AnnotationIntent, scope: "line" | "file"): void {
    const file = this.activeFile;
    const row = scope === "line" ? file.rows[this.selectedRow] : undefined;
    const side = scope === "file" ? "file" : row == null ? null : sideForRow(row);
    const line = scope === "file" ? null : row == null ? null : lineForRow(row);
    if (side == null || line == null && scope === "line") {
      this.message = "Select an added or deleted line first.";
      return;
    }

    const existing = this.annotationFor(file, side, line);
    this.editTarget = {
      fileIndex: this.fileIndex,
      side,
      line,
      intent: existing?.intent ?? intent,
    };
    this.editor.setText(existing?.body ?? "");
    this.message = null;
    this.requestRender();
  }

  private editSelected(): void {
    const row = this.activeFile.rows[this.selectedRow];
    const side = row == null ? null : sideForRow(row);
    const line = row == null ? null : lineForRow(row);
    const existing = side == null ? undefined : this.annotationFor(this.activeFile, side, line);
    if (existing == null) {
      this.message = "No line annotation here. Use f for a FIX or d for a DISCUSS item.";
      return;
    }
    this.openEditor(existing.intent, "line");
  }

  private deleteSelected(): void {
    const row = this.activeFile.rows[this.selectedRow];
    const side = row == null ? null : sideForRow(row);
    const line = row == null ? null : lineForRow(row);
    if (side == null) {
      this.message = "Select an annotation to delete.";
      return;
    }
    this.deleteAnnotation(side, line, "No line annotation here.");
  }

  private deleteAnnotation(side: AnnotationSide, line: number | null, missingMessage: string): void {
    const id = annotationId(this.activeFile.path, side, line);
    const before = this.annotations.length;
    this.annotations = this.annotations.filter((annotation) => annotation.id !== id);
    this.message = before === this.annotations.length ? missingMessage : "Annotation deleted.";
  }

  private editFileAnnotation(): void {
    const existing = this.annotationFor(this.activeFile, "file", null);
    if (existing == null) {
      this.message = "No file annotation here. Use F for a FIX or D for a DISCUSS item.";
      return;
    }
    this.openEditor(existing.intent, "file");
  }

  private saveEditor(): void {
    const target = this.editTarget;
    if (target == null) return;

    const file = this.data.files[target.fileIndex]!;
    const id = annotationId(file.path, target.side, target.line);
    const body = this.editor.getText().trim();
    this.annotations = this.annotations.filter((annotation) => annotation.id !== id);
    if (body.length > 0) {
      this.annotations.push({
        id,
        filePath: file.path,
        side: target.side,
        line: target.line,
        intent: target.intent,
        body,
      });
    }
    this.editTarget = null;
    this.message = body.length > 0 ? "Annotation saved." : "Empty annotation removed.";
    this.requestRender();
  }

  private handleEditorInput(data: string): void {
    if (matchesKey(data, Key.escape)) {
      this.editTarget = null;
      this.message = "Annotation edit cancelled.";
    } else if (matchesKey(data, "shift+enter")) {
      this.editor.handleInput(data);
    } else if (matchesKey(data, Key.enter)) {
      this.saveEditor();
      return;
    } else if (matchesKey(data, Key.tab)) {
      if (this.editTarget != null) {
        this.editTarget = { ...this.editTarget, intent: this.editTarget.intent === "fix" ? "question" : "fix" };
      }
    } else {
      this.editor.handleInput(data);
    }
    this.requestRender();
  }

  handleInput(data: string): void {
    if (this.editTarget != null) {
      this.handleEditorInput(data);
      return;
    }

    if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
      this.done(null);
      return;
    }
    if (matchesKey(data, Key.tab)) {
      this.focus = this.focus === "files" ? "diff" : "files";
    } else if (matchesKey(data, Key.left)) {
      this.focus = "files";
    } else if (matchesKey(data, Key.right)) {
      this.focus = "diff";
    } else if (matchesKey(data, Key.enter) && this.focus === "files") {
      this.focus = "diff";
    } else if (matchesKey(data, "j") || matchesKey(data, Key.down)) {
      if (this.focus === "files") this.moveFile(1); else this.moveDiff(1);
    } else if (matchesKey(data, "k") || matchesKey(data, Key.up)) {
      if (this.focus === "files") this.moveFile(-1); else this.moveDiff(-1);
    } else if (matchesKey(data, Key.rightbracket)) {
      this.moveFile(1);
    } else if (matchesKey(data, Key.leftbracket)) {
      this.moveFile(-1);
    } else if (matchesKey(data, "n")) {
      this.jumpHunk(1);
    } else if (matchesKey(data, "p")) {
      this.jumpHunk(-1);
    } else if (matchesKey(data, "g")) {
      if (this.focus === "files") this.moveFile(-this.data.files.length); else this.moveDiff(-this.changedRowIndexes().length);
    } else if (matchesKey(data, "shift+g") || data === "G") {
      if (this.focus === "files") this.moveFile(this.data.files.length); else this.moveDiff(this.changedRowIndexes().length);
    } else if (matchesKey(data, "f")) {
      this.openEditor("fix", "line");
      return;
    } else if (matchesKey(data, "d")) {
      this.openEditor("question", "line");
      return;
    } else if (matchesKey(data, "shift+f") || data === "F") {
      this.openEditor("fix", "file");
      return;
    } else if (matchesKey(data, "shift+d") || data === "D") {
      this.openEditor("question", "file");
      return;
    } else if (matchesKey(data, "e")) {
      this.editSelected();
    } else if (matchesKey(data, "shift+e") || data === "E") {
      this.editFileAnnotation();
    } else if (matchesKey(data, "x")) {
      this.deleteSelected();
    } else if (matchesKey(data, "shift+x") || data === "X") {
      this.deleteAnnotation("file", null, "No file annotation here.");
    } else if (matchesKey(data, "s")) {
      if (this.annotations.length === 0) this.message = "Add at least one annotation before sending.";
      else this.done(this.annotations);
      return;
    }
    this.requestRender();
  }

  private renderFiles(width: number, height: number): string[] {
    const contentHeight = Math.max(1, height - 2);
    if (this.fileIndex < this.fileScroll) this.fileScroll = this.fileIndex;
    if (this.fileIndex >= this.fileScroll + contentHeight) this.fileScroll = this.fileIndex - contentHeight + 1;

    return this.data.files.slice(this.fileScroll, this.fileScroll + contentHeight).map((file, index) => {
      const absoluteIndex = this.fileScroll + index;
      const selected = absoluteIndex === this.fileIndex;
      const comments = this.annotations.filter((annotation) => annotation.filePath === file.path).length;
      const suffix = comments > 0 ? ` ${this.theme.fg("warning", `●${comments}`)}` : "";
      const label = `${selected ? "›" : " "} ${file.status} ${file.path}${suffix}`;
      return selected ? this.theme.bg("selectedBg", label) : this.theme.fg("muted", label);
    });
  }

  private renderDiff(width: number, height: number): string[] {
    const contentHeight = Math.max(1, height - 2);
    if (this.selectedRow >= 0) {
      if (this.selectedRow < this.diffScroll) this.diffScroll = this.selectedRow;
      if (this.selectedRow >= this.diffScroll + contentHeight) this.diffScroll = this.selectedRow - contentHeight + 1;
    }

    return this.activeFile.rows.slice(this.diffScroll, this.diffScroll + contentHeight).map((row, index) => {
      const rowIndex = this.diffScroll + index;
      const side = sideForRow(row);
      const line = lineForRow(row);
      const annotation = side == null ? undefined : this.annotationFor(this.activeFile, side, line);
      const marker = annotation == null ? " " : annotation.intent === "fix" ? "●" : "?";
      const sign = row.kind === "added" ? "+" : row.kind === "deleted" ? "-" : " ";
      const number = line == null ? "    " : String(line).padStart(4, " ");
      let text = `${rowIndex === this.selectedRow ? "›" : " "}${marker}${sign}${number} ${row.text}`;
      if (rowIndex === this.selectedRow) text = this.theme.bg("selectedBg", text);
      else if (row.kind === "added") text = this.theme.fg("toolDiffAdded", text);
      else if (row.kind === "deleted") text = this.theme.fg("toolDiffRemoved", text);
      else text = this.theme.fg("toolDiffContext", text);
      return text;
    });
  }

  private renderControls(): string[] {
    const key = (text: string) => this.theme.fg("accent", this.theme.bold(text));
    const fix = (text: string) => this.theme.fg("success", this.theme.bold(text));
    const discuss = (text: string) => this.theme.fg("warning", this.theme.bold(text));
    const text = (value: string) => this.theme.fg("dim", value);
    return [
      `${key("Tab/←→")} ${text("panes")}  ${key("j/k")} ${text("move")}  ${key("[/]")} ${text("files")}  ${key("n/p")} ${text("hunks")}`,
      `${fix("f/F")} ${text("FIX line/file")}  ${discuss("d/D")} ${text("DISCUSS line/file")}  ${key("e/x")} ${text("line edit/delete")}  ${key("s")} ${text("send")}  ${key("Esc")} ${text("cancel")}`,
    ];
  }

  private renderWorkspace(width: number, height: number): string[] {
    const innerWidth = Math.max(1, width - 2);
    const status = `${this.annotations.length} annotation${this.annotations.length === 1 ? "" : "s"} • ${this.activeFile.path}`;
    const header = [
      this.theme.fg("muted", status),
      ...(this.message == null ? [] : [this.theme.fg("warning", this.message)]),
      ...this.renderControls(),
      "",
    ];
    const bodyHeight = Math.max(6, height - 2 - header.length);

    if (innerWidth < 82) {
      const fileHeight = Math.min(7, Math.max(3, Math.floor(bodyHeight * 0.3)));
      const diffHeight = Math.max(3, bodyHeight - fileHeight);
      return [
        ...header,
        ...renderPane(this.theme, "Files", this.focus === "files", innerWidth, fileHeight, this.renderFiles(innerWidth, fileHeight)),
        ...renderPane(this.theme, "Diff", this.focus === "diff", innerWidth, diffHeight, this.renderDiff(innerWidth, diffHeight)),
      ];
    }

    const filesWidth = Math.max(24, Math.min(36, Math.floor(innerWidth * 0.3)));
    const diffWidth = Math.max(24, innerWidth - filesWidth - 1);
    const files = renderPane(this.theme, "Files", this.focus === "files", filesWidth, bodyHeight, this.renderFiles(filesWidth, bodyHeight));
    const diff = renderPane(this.theme, "Diff", this.focus === "diff", diffWidth, bodyHeight, this.renderDiff(diffWidth, bodyHeight));
    return [...header, ...Array.from({ length: bodyHeight }, (_, index) => `${files[index] ?? ""} ${diff[index] ?? ""}`)];
  }

  private renderEditor(width: number, height: number): string[] {
    const target = this.editTarget!;
    const file = this.data.files[target.fileIndex]!;
    const location = target.side === "file" ? file.path : `${file.path}:${target.line} (${target.side})`;
    this.editor.focused = this.focused;
    const editorLines = this.editor.render(Math.max(12, width - 6));
    const key = (text: string) => this.theme.fg("accent", this.theme.bold(text));
    const help = `${key("Tab")} ${this.theme.fg("dim", "toggle")}  ${key("Enter")} ${this.theme.fg("dim", "save")}  ${key("Shift+Enter")} ${this.theme.fg("dim", "newline")}  ${key("Esc")} ${this.theme.fg("dim", "cancel")}`;
    return [
      this.theme.fg("muted", location),
      target.intent === "fix" ? this.theme.fg("success", "[FIX]") : this.theme.fg("warning", "[DISCUSS]"),
      help,
      "",
      ...editorLines.slice(0, Math.max(1, height - 6)).map((line) => ` ${line}`),
    ];
  }

  render(width: number): string[] {
    const safeWidth = Math.max(40, width);
    const terminalRows = this.tui.terminal.rows || 24;
    const height = Math.max(10, terminalRows - 2);
    const workspace = renderFrame(this.theme, safeWidth, height, "discuss", this.renderWorkspace(safeWidth, height));
    if (this.editTarget == null) return workspace;

    const formWidth = Math.min(Math.max(36, safeWidth - 8), 72);
    const formHeight = Math.min(Math.max(10, height - 6), 16);
    const form = renderFrame(this.theme, formWidth, formHeight, "Add annotation", this.renderEditor(formWidth, formHeight));
    return renderCenteredOverlay(workspace, form, safeWidth);
  }
}

export async function runDiscussionReview(ctx: ExtensionContext, data: ReviewData): Promise<Annotation[] | null | undefined> {
  return ctx.ui.custom<Annotation[] | null>(
    (tui, theme, _keybindings, done) => new DiscussionReviewApp(tui, theme, done, data),
    {
      overlay: true,
      overlayOptions: {
        anchor: "center",
        width: "100%",
        maxHeight: "100%",
        minWidth: 40,
        margin: 1,
      },
    },
  );
}
