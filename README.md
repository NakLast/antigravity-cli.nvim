# antigravity.nvim

`antigravity.nvim` is a Neovim plugin that integrates the **Antigravity AI Assistant** directly into your editor using a persistent floating terminal. 

It keeps the context alive between toggles so you can chat with the AI, drop down into the terminal, and quickly jump back to your code.

## Installation

You can install this plugin using any popular Neovim package manager.

**Using [lazy.nvim](https://github.com/folke/lazy.nvim):**

```lua
{
    dir = "/home/swd/.gemini/antigravity-cli/scratch/antigravity.nvim", -- Update this path to where you moved the directory!
    config = function()
        require("antigravity").setup({
            -- You can override the default command here if needed
            cmd = "antigravity-cli",
            width_ratio = 0.8,
            height_ratio = 0.8,
            border = "rounded",
        })
    end
}
```

## Usage

Simply run:
```vim
:Antigravity
```
This will open a floating terminal running the CLI. 
Run `:Antigravity` again to hide it without losing your session!

You can also bind it to a key for quicker access. For example:
```lua
vim.keymap.set('n', '<leader>ag', '<cmd>Antigravity<cr>', { desc = 'Toggle Antigravity' })
```

## Configuration

You can customize the floating window and the command to run:
```lua
require("antigravity").setup({
    cmd = "antigravity-cli", -- Default command to spawn the agent
    width_ratio = 0.8,       -- Float window width (80% of screen)
    height_ratio = 0.8,      -- Float window height (80% of screen)
    border = "rounded",      -- Window border style
})
```
# antigravity-cli.nvim
