return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    exclude = {
      filetypes = {
        'lspinfo',
        'packer',
        'checkhealth',
        'help',
        'dashboard',
      },
    },
  },
}
