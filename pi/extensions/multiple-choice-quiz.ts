import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
    Editor,
    type EditorTheme,
    Key,
    matchesKey,
    Text,
    visibleWidth,
    wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface QuizOption {
    label: string;
    explanation: string;
}

type QuizStatus = "correct" | "incorrect" | "cancelled" | "unavailable";

interface QuizResultDetails {
    status: QuizStatus;
    question: string;
    options: QuizOption[];
    correctOption: number;
    selectedOption?: number;
    note?: string;
    message?: string;
}

interface QuizSubmission {
    selectedOption: number;
    note?: string;
}

const QuizOptionSchema = Type.Object({
    label: Type.String({
        minLength: 1,
        description: "The answer option shown to the user. Keep it concise and do not reveal whether it is correct.",
    }),
    explanation: Type.String({
        minLength: 1,
        description:
            "A detailed conceptual explanation of why this option is correct or incorrect. Address the likely reasoning behind the option, relevant definitions or principles, and the exact distinction that makes it right or wrong.",
    }),
});

const MultipleChoiceQuizParams = Type.Object({
    question: Type.String({
        minLength: 1,
        description: "The multiple-choice question used to assess the user's understanding.",
    }),
    options: Type.Array(QuizOptionSchema, {
        minItems: 4,
        maxItems: 4,
        description: "Exactly four plausible answer options in the order they should be displayed.",
    }),
    correctOption: Type.Integer({
        minimum: 1,
        maximum: 4,
        description: "The 1-based number of the single correct option.",
    }),
});

function createEditorTheme(theme: any): EditorTheme {
    return {
        borderColor: (text) => theme.fg("accent", text),
        selectList: {
            selectedPrefix: (text) => theme.fg("accent", text),
            selectedText: (text) => theme.fg("accent", text),
            description: (text) => theme.fg("muted", text),
            scrollInfo: (text) => theme.fg("dim", text),
            noMatch: (text) => theme.fg("warning", text),
        },
    };
}

function addWrapped(lines: string[], text: string, width: number, prefix = ""): void {
    const prefixWidth = visibleWidth(prefix);
    if (prefixWidth >= width) {
        lines.push(...wrapTextWithAnsi(prefix + text, width));
        return;
    }

    const wrapped = wrapTextWithAnsi(text, Math.max(1, width - prefixWidth));
    const continuationPrefix = " ".repeat(prefixWidth);
    for (let index = 0; index < wrapped.length; index++) {
        lines.push(`${index === 0 ? prefix : continuationPrefix}${wrapped[index]}`);
    }
}

function makeDetails(
    status: QuizStatus,
    question: string,
    options: QuizOption[],
    correctOption: number,
    extra: Partial<Pick<QuizResultDetails, "selectedOption" | "note" | "message">> = {},
): QuizResultDetails {
    return { status, question, options, correctOption, ...extra };
}

function cancelledResult(question: string, options: QuizOption[], correctOption: number) {
    const message = "User cancelled the quiz without submitting an answer.";
    return {
        content: [{ type: "text" as const, text: message }],
        details: makeDetails("cancelled", question, options, correctOption, { message }),
    };
}

function unavailableResult(question: string, options: QuizOption[], correctOption: number, message: string) {
    return {
        content: [{ type: "text" as const, text: message }],
        details: makeDetails("unavailable", question, options, correctOption, { message }),
    };
}

function gradedResult(
    question: string,
    options: QuizOption[],
    correctOption: number,
    submission: QuizSubmission,
) {
    const selected = options[submission.selectedOption - 1];
    const correct = options[correctOption - 1];
    const isCorrect = submission.selectedOption === correctOption;
    const noteText = submission.note
        ? `User's optional reasoning note:\n${submission.note}`
        : "The user did not provide a reasoning note, so their reasoning cannot be independently verified.";

    const text = isCorrect
        ? [
              "PASS — The selected answer is correct.",
              `Selected answer: ${submission.selectedOption}. ${selected.label}`,
              "Why it is correct:",
              selected.explanation,
              noteText,
              "Assess the reasoning note separately from the selected answer. A correct choice alone does not prove sound understanding.",
          ].join("\n\n")
        : [
              "FAIL — The selected answer is incorrect.",
              `Selected answer: ${submission.selectedOption}. ${selected.label}`,
              "Why the selected answer is wrong:",
              selected.explanation,
              `Correct answer: ${correctOption}. ${correct.label}`,
              "Why the correct answer is right:",
              correct.explanation,
              noteText,
              "Use the response and reasoning note to identify the specific misconception, not merely that the option number was wrong.",
          ].join("\n\n");

    return {
        content: [{ type: "text" as const, text }],
        details: makeDetails(isCorrect ? "correct" : "incorrect", question, options, correctOption, {
            selectedOption: submission.selectedOption,
            note: submission.note,
        }),
    };
}

async function showQuiz(
    ctx: ExtensionContext,
    question: string,
    options: QuizOption[],
): Promise<QuizSubmission | null> {
    return ctx.ui.custom<QuizSubmission | null>((tui, theme, _keybindings, done) => {
        let optionIndex = 0;
        let selectedOption: number | undefined;
        let step: "answer" | "note" = "answer";
        let parentFocused = false;
        let cachedWidth: number | undefined;
        let cachedLines: string[] | undefined;
        const editor = new Editor(tui, createEditorTheme(theme));

        function refresh(): void {
            cachedWidth = undefined;
            cachedLines = undefined;
            editor.focused = parentFocused && step === "note";
            tui.requestRender();
        }

        function continueToNote(index: number): void {
            optionIndex = index;
            selectedOption = index + 1;
            step = "note";
            refresh();
        }

        editor.onSubmit = (value) => {
            if (selectedOption === undefined) return;
            const note = value.trim();
            done({ selectedOption, note: note || undefined });
        };

        function handleInput(data: string): void {
            if (step === "note") {
                if (matchesKey(data, Key.escape)) {
                    step = "answer";
                    refresh();
                    return;
                }
                editor.handleInput(data);
                refresh();
                return;
            }

            if (matchesKey(data, Key.up)) {
                optionIndex = Math.max(0, optionIndex - 1);
                refresh();
                return;
            }
            if (matchesKey(data, Key.down)) {
                optionIndex = Math.min(options.length - 1, optionIndex + 1);
                refresh();
                return;
            }
            if (matchesKey(data, Key.enter)) {
                continueToNote(optionIndex);
                return;
            }
            if (/^[1-4]$/.test(data)) {
                continueToNote(Number(data) - 1);
                return;
            }
            if (matchesKey(data, Key.escape)) {
                done(null);
            }
        }

        function render(width: number): string[] {
            const renderWidth = Math.max(1, width);
            if (cachedLines && cachedWidth === renderWidth) return cachedLines;

            const lines: string[] = [];
            lines.push(theme.fg("accent", "─".repeat(renderWidth)));
            addWrapped(lines, theme.fg("toolTitle", theme.bold("Multiple-choice quiz")), renderWidth, " ");
            lines.push("");
            addWrapped(lines, theme.fg("text", question), renderWidth, " ");
            lines.push("");

            for (let index = 0; index < options.length; index++) {
                const focused = step === "answer" && index === optionIndex;
                const chosen = selectedOption === index + 1;
                const prefix = focused
                    ? theme.fg("accent", "> ")
                    : chosen
                      ? theme.fg("accent", "✓ ")
                      : "  ";
                const label = `${index + 1}. ${options[index].label}`;
                const color = focused || chosen ? "accent" : "text";
                addWrapped(lines, theme.fg(color, label), renderWidth, prefix);
            }

            lines.push("");
            if (step === "note") {
                addWrapped(
                    lines,
                    theme.fg("muted", "Reasoning note (optional) — explain how you reached your answer:"),
                    renderWidth,
                    " ",
                );
                for (const line of editor.render(Math.max(1, renderWidth - 2))) {
                    addWrapped(lines, line, renderWidth, " ");
                }
                lines.push("");
                addWrapped(
                    lines,
                    theme.fg("dim", "Enter submit • Shift+Enter newline • Esc change answer"),
                    renderWidth,
                    " ",
                );
            } else {
                addWrapped(
                    lines,
                    theme.fg("dim", "↑↓ navigate • 1–4 choose • Enter continue • Esc cancel"),
                    renderWidth,
                    " ",
                );
            }
            lines.push(theme.fg("accent", "─".repeat(renderWidth)));

            cachedWidth = renderWidth;
            cachedLines = lines;
            return lines;
        }

        return {
            get focused() {
                return parentFocused;
            },
            set focused(value: boolean) {
                parentFocused = value;
                editor.focused = value && step === "note";
            },
            render,
            handleInput,
            invalidate() {
                cachedWidth = undefined;
                cachedLines = undefined;
                editor.invalidate();
            },
        };
    });
}

export default function multipleChoiceQuiz(pi: ExtensionAPI) {
    pi.registerTool({
        name: "multiple_choice_quiz",
        label: "Multiple-choice quiz",
        description:
            "Assess the user's understanding with one multiple-choice question containing exactly four options and one correct answer. The user selects an answer and may add an optional reasoning note. The result grades the choice and returns detailed feedback for the selected and correct options so the agent can diagnose misconceptions and independently assess the user's reasoning.",
        promptSnippet:
            "Present one four-option knowledge-check question, collect an optional reasoning note, and grade the response with detailed feedback.",
        promptGuidelines: [
            "Use multiple_choice_quiz when the user should actively demonstrate their current understanding rather than merely receive an explanation.",
            "When calling multiple_choice_quiz, provide exactly four plausible options with one unambiguously correct answer and detailed conceptual explanations for every option.",
            "Do not reveal the correct multiple_choice_quiz answer in the question or option labels; keep correctness and feedback in the hidden tool arguments until submission.",
            "After multiple_choice_quiz returns, assess any reasoning note independently: a correct option chosen for incorrect reasons does not demonstrate understanding.",
        ],
        parameters: MultipleChoiceQuizParams,
        executionMode: "sequential",

        async execute(_toolCallId, params, signal, _onUpdate, ctx) {
            const question = params.question.trim();
            const options = params.options.map((option) => ({
                label: option.label.trim(),
                explanation: option.explanation.trim(),
            }));

            if (signal?.aborted) {
                return cancelledResult(question, options, params.correctOption);
            }
            if (ctx.mode !== "tui") {
                return unavailableResult(
                    question,
                    options,
                    params.correctOption,
                    "multiple_choice_quiz requires Pi's interactive TUI.",
                );
            }
            if (options.length !== 4 || params.correctOption < 1 || params.correctOption > 4) {
                return unavailableResult(
                    question,
                    options,
                    params.correctOption,
                    "Invalid quiz: exactly four options and a correctOption from 1 through 4 are required.",
                );
            }

            const submission = await showQuiz(ctx, question, options);
            if (!submission) {
                return cancelledResult(question, options, params.correctOption);
            }
            return gradedResult(question, options, params.correctOption, submission);
        },

        renderCall(args, theme) {
            const options = Array.isArray(args.options) ? (args.options as QuizOption[]) : [];
            let text = theme.fg("toolTitle", theme.bold("quiz ")) + theme.fg("muted", args.question || "");
            if (options.length > 0) {
                text += `\n${options.map((option, index) => theme.fg("dim", `  ${index + 1}. ${option.label}`)).join("\n")}`;
            }
            return new Text(text, 0, 0);
        },

        renderResult(result, _renderOptions, theme) {
            const details = result.details as QuizResultDetails | undefined;
            if (!details) {
                const first = result.content[0];
                return new Text(first?.type === "text" ? first.text : "", 0, 0);
            }
            if (details.status === "cancelled") {
                return new Text(theme.fg("warning", details.message || "Quiz cancelled"), 0, 0);
            }
            if (details.status === "unavailable") {
                return new Text(theme.fg("warning", details.message || "Quiz unavailable"), 0, 0);
            }

            const selected = details.options[details.selectedOption! - 1];
            const correct = details.options[details.correctOption - 1];
            const note = details.note
                ? `${theme.fg("muted", theme.bold("Reasoning note:"))}\n${details.note}`
                : theme.fg("dim", "Reasoning note: not provided");

            if (details.status === "correct") {
                const text = [
                    theme.fg("success", theme.bold("✓ Correct")),
                    theme.fg("accent", `${details.selectedOption}. ${selected.label}`),
                    theme.fg("muted", theme.bold("Explanation:")),
                    selected.explanation,
                    note,
                ].join("\n\n");
                return new Text(text, 0, 0);
            }

            const text = [
                theme.fg("error", theme.bold("✗ Incorrect")),
                `${theme.fg("muted", "Your answer: ")}${details.selectedOption}. ${selected.label}`,
                theme.fg("error", theme.bold("Why this option is wrong:")),
                selected.explanation,
                `${theme.fg("success", theme.bold("Correct answer:"))} ${details.correctOption}. ${correct.label}`,
                theme.fg("success", theme.bold("Why it is correct:")),
                correct.explanation,
                note,
            ].join("\n\n");
            return new Text(text, 0, 0);
        },
    });
}
