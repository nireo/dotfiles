---
name: anki-card-maker
description: Create high-quality Anki flashcards from user-specified material in importable Front/Back TSV format with HTML fields. Use when the user asks for Anki cards, flashcards, spaced-repetition cards, exam cards, or study cards from notes, PDFs, transcripts, slides, codebase docs, or other source material.
---

Create Anki flashcards from the material the user points to.

The user may point to material by:
- pasting it directly
- uploading a file
- giving a local path such as `./notes/chapter_3.md`
- giving a URL, if web access is available
- referring to project files such as “use the notes in `docs/`”
- referring to prior context such as “use the uploaded PDF”

If the material is not identified, ask the user to provide or point to it.

If the material can be found by exploring the workspace, explore the workspace instead of asking the user to paste it.

Output the cards as TSV with exactly two fields: Front and Back.

Rules:
- First row must be exactly: `Front<TAB>Back`
- Use one physical line per card.
- Use exactly one tab between Front and Back.
- Do not use tabs anywhere else.
- Do not add extra columns.
- Do not wrap fields in quotes.
- Do not use Markdown inside the card fields.
- Use HTML inside fields.
- Use `<br>` for line breaks inside a field.
- Use `<ul><li>...</li></ul>` for lists.
- Use `<b>...</b>` for key terms.
- Use `<i>...</i>` sparingly.
- Do not include commentary before or after the TSV unless the user asks for it.

Card quality:
- Cover the main points of the material.
- Prefer many focused cards over a few overloaded cards.
- Each Front should be a clear, specific question or prompt.
- Each Back should be complete enough to understand the concept.
- Include definitions, mechanisms, examples, distinctions, causes, effects, steps, exceptions, and implications when present.
- Include comparison cards when the material contrasts related concepts.
- Include sequence cards when the material describes a process.
- Include cause-effect cards when the material explains a mechanism.
- Avoid vague fronts like “Explain X” unless synthesis is genuinely required.
- Avoid trivial cards unless the detail is clearly important.
- Do not invent facts not supported by the material.
- Do not copy long passages verbatim.

Example user request:

Create Anki cards from `./biology/chapter_4.md`. Make them detailed and importable.

Example source material:

Active recall is a learning technique where a student retrieves information from memory instead of passively rereading notes. It strengthens memory because retrieval itself improves later recall.

Spaced repetition is the practice of reviewing information at increasing intervals. Difficult material is reviewed more often, while easier material is reviewed less often.

Mitosis is a type of cell division that produces two genetically identical daughter cells. It is used for growth, repair, and asexual reproduction. Meiosis produces four genetically different gametes and reduces the chromosome number by half.

Example output:

Front	Back
What is <b>active recall</b>?	<b>Active recall</b> is a learning technique where the learner retrieves information from memory instead of passively rereading notes.<br><ul><li>It forces recall rather than recognition.</li><li>It strengthens later memory.</li><li>Flashcards and practice questions are common active recall tools.</li></ul>
Why does <b>active recall</b> strengthen memory?	<b>Active recall</b> strengthens memory because the act of retrieval improves later recall.<br><ul><li>Retrieval is not only a test of knowledge.</li><li>It is also a way to build knowledge.</li><li>It helps reveal weak or incomplete understanding.</li></ul>
What is <b>spaced repetition</b>?	<b>Spaced repetition</b> is the practice of reviewing information at increasing intervals.<br><ul><li>Material is reviewed over time instead of all at once.</li><li>Difficult material is reviewed more often.</li><li>Easy material is reviewed less often.</li></ul>
How does <b>spaced repetition</b> treat difficult versus easy material?	<b>Spaced repetition</b> changes review frequency based on difficulty.<br><ul><li><b>Difficult material:</b> reviewed more often.</li><li><b>Easy material:</b> reviewed less often.</li><li>This makes review time more efficient.</li></ul>
What is <b>mitosis</b>?	<b>Mitosis</b> is cell division that produces two genetically identical daughter cells.<br><ul><li>It preserves genetic identity.</li><li>It is used for growth and repair.</li><li>It can also support asexual reproduction.</li></ul>
What is <b>meiosis</b>?	<b>Meiosis</b> is cell division that produces four genetically different gametes.<br><ul><li>It reduces chromosome number by half.</li><li>It creates genetic variation.</li><li>It is used in sexual reproduction.</li></ul>
How do <b>mitosis</b> and <b>meiosis</b> differ?	<b>Mitosis</b> produces two genetically identical daughter cells, while <b>meiosis</b> produces four genetically different gametes.<br><ul><li><b>Mitosis:</b> growth, repair, and asexual reproduction.</li><li><b>Meiosis:</b> gamete production for sexual reproduction.</li><li><b>Mitosis</b> preserves chromosome number; <b>meiosis</b> halves it.</li></ul>

Before final output, check:
- exactly two columns
- first row is `Front<TAB>Back`
- one card per line
- no tabs except between Front and Back
- valid basic HTML
- no unsupported facts
- main points are covered
