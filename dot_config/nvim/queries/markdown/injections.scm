; Local override for Neovim 0.12.x markdown injections.
; Upstream fenced code block injections can hit `node:range()` crashes during
; directive processing on this Neovim version, especially when renderers force
; frequent parse cycles. Keep metadata/html/inline injections, but skip fenced
; code block language injection until the underlying Treesitter issue is fixed.

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
