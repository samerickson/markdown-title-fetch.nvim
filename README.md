# Markdown Title Fetch for Neovim

Automatically fetches the title of a webpage and formats a markdown link. The plugin creates a command `MarkdownLinkPaste` that takes the contents of the register, and if they it is a url, fetches the title of the url and formats a markdown link adding it to the current buffer at the current location. If the link does not contain a webpage with a `<title>` tag, then the domain of the url will be used instead.

If the contents of the register is not a link, then the contents will be pasted as is.

## Example

`https://github.com` will become [github.com](https://github.com), and `https://stackoverflow.com/` becomes [Stack Overflow - Where Developers Learn, Share, &amp; Build Careers](https://stackoverflow.com/), and finally `test123` becomes `test123`.

## Setting up keybindings

You can setup an `autocmd` to add a custom keybinding:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.keymap.set("i", "<C-v>", "<cmd>MarkdownLinkPaste<cr>", { buffer = true, silent = true })
  end,
})
```

## Installation

### Lazy.nvim

For more information see: [GitHub - folke/lazy.nvim: 💤 A modern plugin manager for Neovim](https://github.com/folke/lazy.nvim)

```lua
{
  "https://github.com/samerickson/markdown-title-fetch.nvim",
  opts = {
    register = "*", -- The register that the plugin will read link from
  },
  cmd = "MarkdownLinkPaste",
  keys = {
    { "<c-v>", "<cmd>MarkdownLinkPaste<cr>" },
  },
},
```
