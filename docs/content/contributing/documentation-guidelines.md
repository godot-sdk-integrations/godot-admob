---
title: Documentation Guidelines
icon: fontawesome/brands/markdown
---

# Documentation Guidelines

The page defines the standard documentation rules for the project. Following the guidelines below ensures consistent rendering and helps avoid common formatting issues with lists, tables, and admonitions.

## Lists

- Always insert a blank line before starting a list after a paragraph or heading.

Correct:

Text before list.

- Item 1
- Item 2

Incorrect:

Text before list.
- Item 1
- Item 2

## Nested Lists

- Nested list items must be indented using **4 spaces per level**.
- This ensures compatibility with Python Markdown and MkDocs rendering.

Correct:

1. Main item

    - Nested item
    - Nested item

Incorrect:

1. Main item
   - Nested item

## Admonitions

- Admonition blocks `!!! type` must be followed by a **blank line**
- Content inside admonitions must be indented by **4 spaces**

Correct:

!!! note
    This is a properly formatted admonition.

Incorrect:

!!! note
This will not render correctly.

## General Rule

When in doubt, prefer:

- Blank line before block elements (lists, admonitions, tables)
- 4-space indentation for nested content
- Consistency over minimal indentation
