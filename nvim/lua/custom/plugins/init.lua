-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      { '<leader>c', nil, desc = '[C]laude Code' },
      { '<leader>cc', '<cmd>ClaudeCode<cr>', desc = '[C]laude [C]ode toggle' },
      { '<leader>cf', '<cmd>ClaudeCodeFocus<cr>', desc = '[C]laude [F]ocus', mode = { 'n', 't' } },
      { '<leader>cr', '<cmd>ClaudeCode --resume<cr>', desc = '[C]laude [R]esume' },
      { '<leader>cC', '<cmd>ClaudeCode --continue<cr>', desc = '[C]laude [C]ontinue' },
      { '<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', desc = '[C]laude select [M]odel' },
      { '<leader>cb', '<cmd>ClaudeCodeAdd %<cr>', desc = '[C]laude add [B]uffer' },
      { '<leader>cs', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = '[C]laude [S]end selection' },
      {
        '<leader>cs',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = '[C]laude add file from tree',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      { '<leader>ca', '<cmd>ClaudeCodeDiffAccept<cr>', desc = '[C]laude diff [A]ccept' },
      { '<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = '[C]laude [D]iff deny' },
    },
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      -- Keymaps
      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'Harpoon [A]dd file' })

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon toggle menu' })

      -- Jump to specific files
      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end, { desc = 'Harpoon file 1' })

      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end, { desc = 'Harpoon file 2' })

      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end, { desc = 'Harpoon file 3' })

      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end, { desc = 'Harpoon file 4' })

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end, { desc = 'Harpoon previous' })

      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end, { desc = 'Harpoon next' })
    end,
  },
}
