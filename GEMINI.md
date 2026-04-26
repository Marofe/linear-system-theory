# SEL5911 - Linear Systems Theory Slides

This project contains the slide presentations for the course **SEL5911 - Teoria de Sistemas Lineares** (Linear Systems Theory) taught at EESC-USP. The slides are built using [Reveal.js](https://revealjs.com/) and rendered with KaTeX for mathematical notation.

## Project Structure

- **`2025/` & `2026/`**: Contain the HTML files for each lesson (e.g., `aula1.html`). These are the main entry points for the presentations.
- **`images/`**: A central repository for all images and diagrams used across different lessons and years.
- **`dist/` & `plugin/`**: Core Reveal.js files and plugins (Math, Highlight, Notes, Markdown).
- **`style.css`**: Global CSS styles providing a consistent look and feel (e.g., `.lightup` blocks, logo positioning).
- **`init.js`**: Shared Reveal.js initialization script. It configures the presentation dimensions (1333x750), KaTeX delimiters, and custom LaTeX macros.

## Key Files & Customizations

### `init.js`
Centralizes the Reveal.js configuration. It includes custom LaTeX macros for KaTeX:
- `\R`: $\mathbb{R}$
- `\trp`: $\intercal$ (transpose)
- `\diag`, `\Diag`, `\tr`: Operators for diagonal matrices and trace.

It also contains logic to hide slide numbers on slides marked with `data-hide-slide-number="true"`.

### `style.css`
Defines utility classes used throughout the slides:
- `.lightup`: Stylized boxes for highlighting key equations or statements.
- `.slide-title` & `.slide-content`: Standard layout structures for slide headers and body.
- `.logo` & `.logo2`: Positions for institutional logos on the title slides.

### `test`
A scratchpad file containing `<section>` snippets. Used for testing new slide layouts or complex math mappings before integration into the main lesson files.

## Usage

To view or present a lesson:
1. Navigate to the desired year folder (e.g., `2026/`).
2. Open the corresponding HTML file (e.g., `aula1.html`) in any modern web browser.

**Note:** Since the HTML files use relative paths to reach the root directory (e.g., `../style.css`), they must remain inside their respective year folders to function correctly.

## Development Conventions

- **Adding a New Lesson:** Copy an existing `aula*.html` file to use as a template.
- **Equations:** Use `$$ ... $$` for block math and `$ ... $` for inline math, as configured in `init.js`.
- **Images:** Place all new images in the `images/` directory and reference them using `../images/filename`.
- **Styling:** Avoid inline styles; use the classes defined in `style.css` or extend it if necessary.
