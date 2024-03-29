return {
  'jakewvincent/texmagic.nvim',
  init = function()
    require('texmagic').setup {
      engines = {
        pdflatex = {
          executable = 'latexmk',
          args = {
            '-pdflatex',
            '-interaction=nonstopmode',
            '-synctex=1',
            '-outdir=.build',
            '-pv',
            '%f',
          },
          isContinuous = false,
        },
      },
    }
  end,
}
