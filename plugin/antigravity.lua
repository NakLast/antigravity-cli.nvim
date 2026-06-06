if vim.g.loaded_antigravity == 1 then
    return
end
vim.g.loaded_antigravity = 1

vim.api.nvim_create_user_command("Antigravity", function()
    require("antigravity").toggle()
end, { desc = "Toggle Antigravity AI Assistant" })
