---
name: presenterm
description: Create and edit terminal-based presentations using presenterm markdown format
---

# Skill: presenterm

Create and manipulate presentations for [presenterm](https://github.com/mfontanini/presenterm) - a markdown-based terminal slideshow tool.

## Quick Reference

Presentations are plain markdown files. Run with:

```bash
presenterm slides.md
```

Use `--present` for presentation mode (disables hot reload). Use `-x` to enable code execution.

## Slide Structure

### Front Matter (optional intro slide)

```yaml
---
title: "My **Presentation**"
sub_title: Optional subtitle
author: Author Name
---
```

Multiple authors use `authors:` with a YAML list.

### Slide Separator

Slides are separated by the `end_slide` comment command. Do NOT use `---` (thematic breaks) as slide separators unless `end_slide_shorthand` is configured.

```markdown
First slide content

<!-- end_slide -->

Second slide content
```

### Slide Titles

Use setext-style headers for slide titles (rendered centered with special styling):

```markdown
My Slide Title
===
```

Or the underline variant:

```markdown
My Slide Title
---
```

## Comment Commands

All special behaviors use HTML comment syntax. Key commands:

| Command | Purpose |
|---------|---------|
| `<!-- end_slide -->` | End current slide, start new one |
| `<!-- pause -->` | Reveal content incrementally on keypress |
| `<!-- jump_to_middle -->` | Center following content vertically |
| `<!-- new_line -->` | Insert explicit blank line |
| `<!-- new_lines: N -->` | Insert N blank lines |
| `<!-- incremental_lists: true -->` | Auto-pause between list items |
| `<!-- no_footer -->` | Hide footer on this slide |
| `<!-- skip_slide -->` | Exclude slide from presentation |
| `<!-- alignment: center -->` | Set text alignment (left/center/right) |
| `<!-- include: file.md -->` | Include external markdown file |
| `<!-- font_size: 2 -->` | Set font size 1-7 (kitty terminal only) |
| `<!-- speaker_note: text -->` | Add speaker notes |
| `<!-- // comment -->` | User comment (ignored during rendering) |
| `<!-- column_layout: [2, 1] -->` | Define column layout |
| `<!-- column: 0 -->` | Switch to column N |
| `<!-- reset_layout -->` | Exit column layout |
| `<!-- list_item_newlines: 2 -->` | Spacing between list items |

## Column Layouts

Define columns with proportional widths, then write content into each:

```markdown
<!-- column_layout: [2, 1] -->

<!-- column: 0 -->

Left column content (2/3 width)

```python
def hello():
    print("hi")
```

<!-- column: 1 -->

Right column content (1/3 width)

![](image.png)

<!-- reset_layout -->

Content below columns spans full width.
```

Use `[1, 3, 1]` to center content in the middle 60%.

## Code Blocks

### Syntax Highlighting

Standard fenced code blocks with language identifiers. Over 50 languages supported.

### Line Numbers

````markdown
```rust +line_numbers
fn main() {
    println!("Hello");
}
```
````

### No Background

````markdown
```python +no_background
print("clean look")
```
````

### Dynamic Highlighting

Highlight different line subsets on each keypress using `|` separator:

````markdown
```rust {1-3|5-7|all} +line_numbers
struct Config {
    name: String,
    value: u32,
}

impl Config {
    fn new() -> Self { ... }
}
```
````

### Selective Highlighting

Highlight only specific lines (no animation):

````markdown
```rust {2,4}
fn example() {
    let important = true;    // highlighted
    let boring = false;
    let also_important = 42; // highlighted
}
```
````

### Code Execution

Mark blocks executable with `+exec`. Requires `-x` flag or config to enable.

````markdown
```python +exec
print("Hello from Python!")
```
````

Press `ctrl+e` during presentation to execute.

### Hiding Lines

Hide boilerplate while still executing it. Prefix depends on language:
- Rust: lines starting with `#`
- Python/bash/go/js/ts/c/c++/etc: lines starting with `///`

````markdown
```rust +exec
# fn main() {
println!("Only this shows");
# }
```
````

### External Code Files

````markdown
```file +exec +line_numbers
path: code.rs
language: rust
start_line: 5
end_line: 15
```
````

### Execute and Replace

`+exec_replace` runs automatically and replaces the block with output. Requires `-X` flag.

## Images

Standard markdown image syntax. Supported in kitty, iterm2, wezterm, ghostty, foot, and sixel terminals.

```markdown
![](path/to/image.png)
```

## Text Formatting

Standard markdown: **bold**, *italic*, ~strikethrough~, `inline code`, [links](url).

Colored text via `<span>` tags:

```markdown
<span style="color: red">Red text</span>
<span style="color: #ff0000; background-color: black">Custom colors</span>
<span class="my_class">Using theme palette class</span>
```

## Themes

### Set via Front Matter

```yaml
---
theme:
  name: dark
---
```

### Built-in Themes

`dark`, `light`, `terminal-dark`, `terminal-light`, `tokyonight-storm`, `gruvbox-dark`, `catppuccin-latte`, `catppuccin-frappe`, `catppuccin-macchiato`, `catppuccin-mocha`

Preview all: `presenterm --list-themes`

### Theme Overrides in Front Matter

```yaml
---
theme:
  override:
    default:
      colors:
        foreground: "beeeff"
---
```

### Custom Theme Files

Place `.yaml` files in `~/.config/presenterm/themes/` to make them available by name.

## Speaker Notes

Define with `<!-- speaker_note: text -->`. Use two terminal instances:

```bash
# Main presentation
presenterm slides.md --publish-speaker-notes

# Speaker notes viewer (separate terminal)
presenterm slides.md --listen-speaker-notes
```

Multiline notes:

```markdown
<!-- 
speaker_note: |
  First point to mention
  Second point to mention
-->
```

## Common Patterns

### Section Separator Slide

```markdown
<!-- end_slide -->

<!-- jump_to_middle -->

Section Title
===

<!-- end_slide -->
```

### Incremental Bullet Points

```markdown
<!-- incremental_lists: true -->

* First point
* Second point
* Third point
```

### Side-by-Side Code and Image

```markdown
<!-- column_layout: [3, 2] -->

<!-- column: 0 -->

```python
def process(data):
    return transform(data)
```

<!-- column: 1 -->

![](diagram.png)

<!-- reset_layout -->
```

## Docs & Examples

- Full documentation: https://mfontanini.github.io/presenterm/
- Example presentations: https://github.com/mfontanini/presenterm/tree/master/examples
- Demo presentation: https://github.com/mfontanini/presenterm/blob/master/examples/demo.md
- Theme definitions: https://github.com/mfontanini/presenterm/tree/master/themes
