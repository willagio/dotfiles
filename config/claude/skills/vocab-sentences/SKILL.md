# Vocabulary Sentences Skill

This skill takes a list of English words, generates definitions, example sentences, and their Korean translations, then saves them to an Obsidian vault.

## Invocation

User-invocable: true
Skill command: vocab-sentences

## Instructions

### Input Processing

1.  **Parse Input (LLM-first)**: The user input may be highly unstructured (mixed punctuation, slashes, translations, notes, repeated items, broken spacing/newlines). Use LLM semantic extraction as the primary method to identify intended English headwords.
2.  **Do Not Rely on Regex Alone**: Regex can be used only as a secondary sanity check, not as the main extraction strategy.
3.  **Normalize + Deduplicate**: Normalize extracted headwords (trim whitespace, normalize case), then deduplicate.
4.  **Alphabetical Sorting**: Sort the final deduplicated headword list in ascending alphabetical order before generating any content.
5.  **Handle Empty Input**: If no valid words are extracted after normalization, ask the user to provide a list of words.

### Content Generation

For each word in the list, generate the following content. You should use a powerful language model for this task to ensure high-quality and contextually accurate results.

1.  **English Definition**: A clear and concise definition of the word in English.
2.  **Korean Translation of Definition**: The Korean translation of the English definition.
3.  **Pronunciation (Stress-readable, non-IPA; heading only)**: A beginner-friendly pronunciation value that is placed in the H2 heading only (no separate pronunciation line).
4.  **Example Sentence**: An original, illustrative sentence using the word in a natural context.
5.  **Korean Translation of Sentence**: The Korean translation of the example sentence.

### Pronunciation Style (Stress-readable, non-IPA)

Use this exact style for pronunciation:

- Format (for heading): `word [chunk CHUNK chunk]`
- Inside brackets, use easy-to-read respelling (not IPA).
- Inside brackets, use space-separated syllable chunks with single spaces only.
- Do not use hyphens (`-`), slashes (`/`), or extra spacing inside brackets.
- Uppercase the entire primary-stress chunk; keep all other chunks lowercase.

Examples:

- `ARCANE [ar KAYN]`
- `ALACRITY [uh LAK ruh tee]`

Headword casing is flexible. The capitalization rules apply only to chunks inside `[...]` (primary-stress chunk uppercase, others lowercase).

### Output Formatting and Saving

1.  **File Naming**: The output file should be named with the current date, e.g., `YYYY-MM-DD.md`.
2.  **File Path**: Save the file to the user's Obsidian vocabulary subdirectory, located at `~/obsidian-vault/vacabulary/`.
3.  **Directory Check**: If the `~/obsidian-vault/vacabulary/` directory does not exist, create it first, then continue.
4.  **Content Format**: Use the following Markdown format. Each word should be a level-2 heading that includes pronunciation. Separate each word's entry with a horizontal rule (`---`).

`{{pronunciation_#}}` must contain bracket content only (syllable chunks only). Do not include surrounding brackets inside that placeholder.

The file must begin with a YAML frontmatter block, where `id` is the current date string (`YYYY-MM-DD`). This block is only added when creating a new file; never duplicate or modify it when appending to an existing file.

```markdown
---
id: "{{current_date}}"
aliases: []
tags: []
---

# Vocabulary - {{current_date}}

---

## {{word_1}} [{{pronunciation_1}}]

{{english_definition_1}} ({{korean_definition_1}}).

> {{example_sentence_1}}
> {{korean_sentence_1}}

---

## {{word_2}} [{{pronunciation_2}}]

{{english_definition_2}} ({{korean_definition_2}}).

> {{example_sentence_2}}
> {{korean_sentence_2}}

---
```

### Important Rules

- If a file for the current date already exists, append the new vocabulary words to the existing file instead of overwriting it. Check for the existence of the word in the file before appending to avoid duplicates. Keep the existing YAML frontmatter intact and do not add a second one.
- Apply the same normalization when checking for existing words to prevent case/spacing variants from being added as duplicates.
- Ensure all generated content is accurate and natural-sounding in both English and Korean.
- Use the pronunciation format exactly as rendered in the heading template: `## word [chunk CHUNK chunk]` (non-IPA).
- Maintain the exact Markdown structure specified.
- Generate entries in the same alphabetical order as the finalized headword list.
- After saving the file, confirm with the user by providing the absolute path to the saved file.
