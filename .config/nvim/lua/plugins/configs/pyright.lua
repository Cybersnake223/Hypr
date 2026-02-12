return {
  root_dir = vim.fs.root(0, {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'pyrightconfig.json',
    '.git',
  }) or vim.fn.getcwd(),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'workspace',  -- Broader than "openFilesOnly"
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'basic',    -- Or 'strict'
      },
    },
  },
}
