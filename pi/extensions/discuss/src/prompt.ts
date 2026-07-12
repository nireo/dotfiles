export type AnnotationIntent = "fix" | "question";
export type AnnotationSide = "added" | "deleted" | "file";

export interface Annotation {
  id: string;
  filePath: string;
  side: AnnotationSide;
  line: number | null;
  intent: AnnotationIntent;
  body: string;
}

function location(annotation: Annotation): string {
  if (annotation.side === "file" || annotation.line == null) return annotation.filePath;
  return `${annotation.filePath}:${annotation.line} (${annotation.side})`;
}

function appendSection(lines: string[], title: string, annotations: Annotation[]): void {
  if (annotations.length === 0) return;
  lines.push(title, "");
  for (const annotation of annotations) {
    lines.push(`- ${location(annotation)}`);
    for (const line of annotation.body.trim().split(/\r?\n/)) lines.push(`  ${line}`);
  }
}

/** Formats annotations as explicit instructions for the active Pi agent. */
export function composeDiscussionPrompt(annotations: Annotation[]): string {
  const fixes = annotations.filter((annotation) => annotation.intent === "fix");
  const questions = annotations.filter((annotation) => annotation.intent === "question");
  const lines = [
    "Process the following diff review feedback against the current working tree.",
    "",
    "Rules:",
    "- Make the requested code changes for FIX items.",
    "- Answer QUESTION items clearly in prose. Do not change code merely to answer a question.",
    "- If both sections are present, implement FIX items and answer QUESTION items separately.",
    "",
  ];

  appendSection(lines, "FIX", fixes);
  if (fixes.length > 0 && questions.length > 0) lines.push("");
  appendSection(lines, "QUESTIONS", questions);

  return lines.join("\n").trim();
}
