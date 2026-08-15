---
name: anki-card-maker
description: Create high-quality Anki flashcards from user-specified material in importable Front/Back TSV format with HTML fields. Use when the user asks for Anki cards, flashcards, spaced-repetition cards, exam cards, or study cards from notes, PDFs, transcripts, slides, codebase docs, mathematical material, technical material, or other source material.
---

# Anki Card Maker

Create high-quality, focused Anki flashcards from source material.

The primary objective is not to maximize the number of cards. It is to create cards that produce durable recall, conceptual understanding, mathematical fluency, and useful problem-solving ability.

For technical and mathematical subjects, prefer cards that test mechanisms, equations, assumptions, derivations, dimensions or structures, implementation consequences, and failure modes rather than cards that merely reproduce prose.

## Workflow

1. **Identify Material**
   - If the user has supplied source material, use it as the primary source of truth.
   - If the user refers to files or notes that have not yet been inspected, read the relevant material first.
   - If the user specifies a topic rather than a source document, create cards only from well-established facts you can state accurately.

2. **Extract & Synthesize**
   - Identify:
     - core concepts,
     - definitions,
     - mechanisms,
     - equations,
     - assumptions,
     - relationships,
     - derivation steps,
     - examples,
     - distinctions,
     - dimensions, shapes, or structural relationships,
     - implementation implications,
     - common failure modes,
     - likely misconceptions.
   - Do not mechanically convert every sentence into a card.
   - Omit low-value trivia unless the user explicitly asks for exhaustive coverage.

3. **Choose Card Types**
   - Select the card type that best tests the knowledge.
   - For technical or mathematical material, use the specialized card types described below.

4. **Generate Cards**
   - Follow the [Formatting Rules](#formatting-rules).
   - Follow the [Card Quality Standards](#card-quality-standards).
   - For mathematical material, also follow the [Math and Equation Rules](#math-and-equation-rules).

5. **Quality Filter**
   - Rewrite or remove cards that are vague, overloaded, trivial, redundant, answer-leaking, or excessively difficult to grade.
   - Prefer a smaller number of excellent cards over a larger number of mediocre cards.

6. **Validate**
   - Before outputting, verify the TSV structure.
   - If available, use `scripts/validate_tsv.cjs` on a temporary file.
   - For mathematical material, also check that MathJax delimiters are balanced and that no physical newline or tab appears inside a field.

---

# Formatting Rules

Output cards as TSV with exactly two fields: **Front** and **Back**.

## TSV structure

- **Header:** First row must be exactly:

```text
Front	Back
```

- **One card per physical line.**
- **Exactly one tab** separates Front and Back.
- **No other tabs** may occur anywhere in the row.
- **No extra columns.**
- **Do not wrap fields in quotes.**
- **Do not place physical line breaks inside a field.**
  - Use `<br>` instead.
- **No Markdown syntax inside card fields.**
  - Do not use `**bold**`, Markdown headings, Markdown lists, fenced code blocks, or Markdown links inside Front or Back.
- The surrounding skill documentation may use Markdown normally. The restriction applies only to generated TSV field contents.

## HTML styling

Use basic HTML inside fields:

- `<br>` for line breaks.
- `<ul><li>...</li></ul>` for short lists.
- `<b>...</b>` for important terms.
- `<i>...</i>` sparingly.
- `<code>...</code>` for short code expressions, API names, technical operations, or identifiers.
- Avoid excessive visual styling.

Example:

```text
What is <b>gradient clipping</b> used for?	<b>Gradient clipping</b> limits gradient magnitude to reduce unstable parameter updates caused by exploding gradients.<br>It is especially useful in models where gradient norms can occasionally become very large.
```

---

# Math and Equation Rules

When the source material contains mathematics, Anki supports MathJax. Use MathJax delimiters directly inside TSV fields.

## Inline equations

Use:

```text
\( y = Wx + b \)
```

Example card:

```text
For the affine transformation \(z = Wx+b\), what is the gradient with respect to \(x\)?	\(\frac{\partial L}{\partial x}=W^\top\frac{\partial L}{\partial z}\)
```

## Display equations

Use:

```text
\[ ... \]
```

Display equations may appear inside a field as long as the entire TSV card remains on one physical line.

Example:

```text
Write the equation for kinetic energy.	\[E_k=\frac{1}{2}mv^2\]
```

## Mathematical notation

Prefer standard notation:

```text
\(\nabla_\theta L\)
\(\frac{\partial L}{\partial W}\)
\(\mathbb{E}[X]\)
\(\operatorname{softmax}(z)\)
\(\arg\max_a Q(s,a)\)
\(x \in \mathbb{R}^{B \times T \times d}\)
```

## Equation quality

Do not create cards that only test visual recognition of a formula when reconstruction or interpretation would be more useful.

Prefer multiple complementary cards:

1. reconstruct the equation,
2. explain each term,
3. explain why the equation has that form,
4. identify its assumptions,
5. apply it to a small case.

For example, for an important equation or model, prefer separate cards for:

- the equation itself,
- why it has that form,
- the meaning of each term,
- the assumptions under which it applies,
- the consequences of changing one variable or condition.

## Derivations

Do not place a long derivation on one card.

Break derivations into **retrievable checkpoints**.

Bad:

```text
Derive backpropagation through a two-layer neural network.	[ten-line derivation]
```

Better:

```text
For \(z=Wx+b\), express \(\frac{\partial L}{\partial W}\) using the upstream gradient \(\frac{\partial L}{\partial z}\).	\(\frac{\partial L}{\partial W}=\frac{\partial L}{\partial z}x^\top\)
```

and:

```text
For \(z=Wx+b\), express \(\frac{\partial L}{\partial x}\) using the upstream gradient.	\(\frac{\partial L}{\partial x}=W^\top\frac{\partial L}{\partial z}\)
```

and:

```text
Why is backpropagation efficient for a scalar loss with many parameters?	It uses reverse-mode automatic differentiation, reusing intermediate derivatives while traversing the computational graph backward, so gradients with respect to many parameters can be computed efficiently in one reverse pass.
```

---

# Card Quality Standards

## 1. Atomicity

Each card should test **one main mental operation**.

Bad:

```text
Explain softmax, cross-entropy, maximum likelihood, and why they are used for classification.
```

Better as separate cards:

```text
What does softmax convert a vector of logits into?
Why does cross-entropy arise naturally in multiclass classification?
Write the multiclass cross-entropy loss.
How is minimizing cross-entropy related to maximum likelihood?
```

A card may contain a few closely related answer components when they form one coherent fact, but avoid mini-essays.

---

## 2. Specific prompts

Avoid vague fronts such as:

```text
Explain photosynthesis.
What is inflation?
Discuss natural selection.
```

Prefer questions with a clear target:

```text
What two quantities determine kinetic energy?
Why does kinetic energy depend on the square of velocity?
How does increasing temperature affect the pressure of a gas in a rigid container?
```

The learner should know exactly what must be recalled.

---

## 3. Minimum information principle

Answers should be as short as possible while remaining correct and meaningful.

Do not create unnecessarily verbose backs.

Bad:

```text
What is dropout?	[large paragraph covering history, implementation, intuition, variants, and caveats]
```

Better:

```text
What does dropout do during training?	It randomly zeros a subset of activations, reducing reliance on specific co-adapted features and acting as a regularizer.
```

Then create separate cards for inference behavior or scaling if those details matter.

---

## 4. Recall over recognition

Prefer free recall.

Avoid unnecessary multiple-choice cards unless the source material or user explicitly calls for them.

Weak:

```text
Which optimizer maintains first- and second-moment estimates? A) SGD B) Adam C) Newton's method
```

Strong:

```text
What two exponential moving averages does Adam maintain?	A first-moment estimate of gradients and a second-moment estimate of squared gradients.
```

---

## 5. Mechanism over wording

Prefer cards that ask **why** or **how** when the mechanism matters.

Weak:

```text
What is the SI unit of force?	The newton, \(\mathrm{N}\).
```

Stronger:

```text
Why does a metal wire typically become more resistive as its temperature rises?	Higher temperature increases lattice vibrations, which scatter conduction electrons more strongly and impede their motion.
```

The weaker factual card may still be useful if exact formula recall is important, but it should not replace the mechanism card.

---

## 6. Explicit context

A card must contain enough context to be answerable independently after weeks or months.

Bad:

```text
Why does this help?	It stabilizes training.
```

Good:

```text
Why can buffering help stabilize the pH of a solution?	A buffer contains a weak acid/base pair that consumes added \(H^+\) or \(OH^-\), reducing the resulting change in pH.
```

Do not rely on neighboring cards for interpretation.

---

## 7. Avoid answer leakage

Do not make the front reveal most of the answer.

Weak:

```text
Why does the residual equation \(y=F(x)+x\) improve gradient flow?
```

Potentially better:

```text
What architectural feature in a residual block gives gradients a direct path through the block?	The identity skip connection, which adds the block input directly to its transformed output.
```

Equation-containing prompts are appropriate when the equation itself is required context for a derivation or shape question.

---

## 8. Gradeability

The learner should be able to decide whether the recalled answer is correct.

Avoid prompts with arbitrarily broad answer spaces.

Bad:

```text
What should you know about the immune system?
```

Good:

```text
Why does parameter sharing make a convolutional layer more parameter-efficient than a fully connected layer on an image?
```

---

## 9. Avoid trivial cards

Do not create cards for facts that are obvious from terminology or can be reconstructed instantly with no useful learning value.

For example, avoid:

```text
What does DNA stand for?	Deoxyribonucleic acid.
```

unless the user is a complete beginner or explicitly requests terminology cards.

---

## 10. Avoid redundancy

Do not create several cards that test effectively the same memory trace with slightly different wording.

Multiple cards about one concept are encouraged only when they test genuinely different dimensions:

- equation,
- mechanism,
- derivation,
- interpretation,
- application,
- failure mode,
- comparison.

---

## 11. Avoid oversized list cards

Long lists are difficult to recall and grade.

Bad:

```text
List every difference between SGD, momentum, RMSProp, Adam, AdamW, Adagrad, and Adadelta.
```

Split into targeted comparisons:

```text
How does momentum modify vanilla SGD?
What additional statistic does Adam track beyond momentum?
How does AdamW differ conceptually from L2 regularization implemented inside Adam?
```

---

## 12. Preserve useful difficulty

Do not oversimplify until the card becomes meaningless.

A good card should require effortful retrieval but still have a reasonably short answer.

For mathematical material, it is often desirable to require the learner to reconstruct an equation or intermediate reasoning step rather than merely name a term.

---

# Specialized Card Types

Use these types when appropriate. Do not force every concept into every type.

## A. Definition cards

Test precise definitions.

Example:

```text
What is an <b>opportunity cost</b>?	The value of the best alternative forgone when a choice is made.
```

---

## B. Mechanism / Why cards

Test causal understanding.

Example:

```text
Why does increasing temperature generally increase the pressure of a gas in a rigid container?	Higher temperature increases the molecules' average kinetic energy, causing more frequent and more forceful collisions with the container walls.
```

These are often among the highest-value cards.

---

## C. Equation reconstruction cards

Ask the learner to produce an equation from memory.

Example:

```text
Write the quadratic formula for \(ax^2+bx+c=0\).	\[x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}\]
```

---

## D. Equation interpretation cards

Test understanding of individual terms.

Example:

```text
In the quadratic formula, what does the discriminant \(b^2-4ac\) determine?	It determines the nature of the roots: positive gives two distinct real roots, zero gives one repeated real root, and negative gives two complex conjugate roots.
```

---

## E. Assumption cards

Many mathematical results are only valid under particular assumptions.

Example:

```text
Under what condition is the approximation \(\sin x\approx x\) valid?	When \(x\) is close to zero and measured in radians.
```

Prefer assumption cards whenever a formula might otherwise be memorized without understanding when it applies.

---

## F. Derivation checkpoint cards

Break a derivation into short, meaningful steps.

Example:

```text
If \(A=\pi r^2\), what is \(\frac{dA}{dr}\)?	\(2\pi r\)
```

The ideal checkpoint is a step the learner should be able to reconstruct during a full derivation.

---

## G. Dimension / shape cards

Use whenever dimensional or structural reasoning is important, such as matrices, arrays, geometry, units, data tables, or structured representations.

Example:

```text
If a matrix \(A\) has shape \(m\times n\) and \(B\) has shape \(n\times p\), what shape does \(AB\) have?	\(m\times p\)
```

Example:

```text
If a vector has 8 components and is reshaped into a \(2\times4\) matrix, how many scalar values does the result contain?	8
```

---

## H. Small calculation cards

Use small numerical examples when they reinforce a general mechanism.

Example:

```text
A solution contains 0.50 mol of solute in 2.0 L of solution. What is its molarity?	\(0.25\,\mathrm{mol/L}\)
```

Keep numbers small enough that the card tests the concept rather than arithmetic endurance.

---

## I. Comparison cards

Use when two concepts are easily confused.

Example:

```text
What is the key difference between <b>mitosis</b> and <b>meiosis</b> in their products?	<b>Mitosis</b> typically produces two genetically similar daughter cells, while <b>meiosis</b> produces four genetically varied haploid cells.
```

Avoid asking for many differences at once.

---

## J. Implementation mapping cards

Connect math to code.

Example:

```text
In a spreadsheet, what does an absolute reference such as <code>$A$1</code> do when a formula is copied?	It keeps both the column and row fixed instead of adjusting them relative to the new formula location.
```

Example:

```text
Why should a database query use parameterized inputs instead of directly concatenating user text into SQL?	Parameterized queries separate data from executable SQL syntax, reducing the risk of SQL injection.
```

Use code cards for mechanisms and semantics, not for memorizing arbitrary syntax.

---

## K. Debugging cards

Turn practical failure modes into reusable knowledge.

Example:

```text
A program starts failing only after a previously optional input becomes empty. What is a useful first debugging hypothesis?	A code path is assuming the value is present and does not correctly handle the empty or null case.
```

Whenever possible, create debugging cards from problems the learner actually encountered.

---

## L. Misconception cards

Target tempting but incorrect intuitions.

Example:

```text
Does correlation by itself establish causation?	No. A correlation can arise from confounding variables, reverse causation, selection effects, or coincidence.
```

These cards are especially useful when a concept is intuitive but easy to state imprecisely.

---

## M. Consequence / What-if cards

Ask what changes when one design choice is altered.

Example:

```text
What happens to the period of a simple pendulum, approximately, if its length is increased while gravity stays constant?	The period increases because \(T=2\pi\sqrt{L/g}\).
```

---

# Card Generation Strategy

When a concept is important, consider generating a **card cluster**.

A high-quality cluster may contain:

1. **Definition**
2. **Equation**
3. **Mechanism**
4. **Interpretation**
5. **Assumption**
6. **Shape or dimensionality**
7. **Implementation implication**
8. **Failure mode or misconception**

Do not create all eight automatically. Use only the dimensions that meaningfully improve understanding.

For foundational or difficult concepts, 2–5 orthogonal cards per concept is often better than one giant card.

---

# Source Fidelity

- Stay grounded in the user's material when source material is provided.
- Do not invent claims or fill gaps with uncertain information.
- You may synthesize across nearby passages when the relationship is well supported.
- If the source uses an imprecise explanation but the intended mathematical fact is clear, improve clarity without changing the meaning.
- If the source appears incorrect or ambiguous, do not silently encode the questionable claim as a flashcard. Flag it or omit it.

---

# Card Selection Heuristic

Before creating a card, ask:

> "Would successfully recalling this help the learner explain, derive, implement, debug, or apply the concept later?"

If not, the card is probably low value.

Especially prioritize knowledge that is:

- foundational,
- frequently reused,
- easily confused,
- mathematically important,
- hard to reconstruct under pressure,
- useful for solving new problems,
- useful for troubleshooting or application,
- likely to appear in coursework, exams, professional practice, or interviews.

---

# Final Quality Checklist

Before outputting each set of cards, verify:

## Structure

1. Header is exactly `Front<TAB>Back`.
2. Exactly two columns per row.
3. Exactly one separator tab per card.
4. No tabs inside fields.
5. No physical newlines inside fields.
6. No surrounding quotes.
7. HTML is valid enough for Anki.
8. MathJax delimiters are balanced.

## Card quality

9. Each card has one main target.
10. The front is specific and independently understandable.
11. The answer is concise and gradeable.
12. The front does not unintentionally reveal the answer.
13. The card tests recall, reasoning, or reconstruction rather than mere recognition.
14. Long derivations are split into checkpoints.
15. Equations are paired with interpretation or mechanism cards when useful.
16. Important assumptions are tested.
17. Dimensions or shapes are tested where dimensional reasoning matters.
18. Redundant cards are removed.
19. Low-value trivia is omitted unless requested.
20. The cards remain grounded in the source material.

---

# Example Output

```text
Front	Back
Why does increasing temperature generally increase the pressure of a gas in a rigid container?	Higher temperature increases the molecules' average kinetic energy, causing more frequent and more forceful collisions with the container walls.
Write the quadratic formula for \(ax^2+bx+c=0\).	\[x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}\]
In the quadratic formula, what does the discriminant \(b^2-4ac\) determine?	It determines the nature of the roots: positive gives two distinct real roots, zero gives one repeated real root, and negative gives two complex conjugate roots.
If a matrix \(A\) has shape \(m\times n\) and \(B\) has shape \(n\times p\), what shape does \(AB\) have?	\(m\times p\)
What is the key difference between <b>mitosis</b> and <b>meiosis</b> in their products?	<b>Mitosis</b> typically produces two genetically similar daughter cells, while <b>meiosis</b> produces four genetically varied haploid cells.
Why should a database query use parameterized inputs instead of directly concatenating user text into SQL?	Parameterized queries separate data from executable SQL syntax, reducing the risk of SQL injection.
Does correlation by itself establish causation?	No. A correlation can arise from confounding variables, reverse causation, selection effects, or coincidence.
```
