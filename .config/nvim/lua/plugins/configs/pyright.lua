return {
  -- ROOT_DIR: Tells Pyright where your project "starts."
  -- It searches upward for these specific files to define the workspace.
  -- This is vital for resolving imports across different folders in your repo.
  root_dir = vim.fs.root(0, {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "pyrightconfig.json",
    ".git",
  }) or vim.fn.getcwd(), -- Falls back to the current directory if no root file is found

  settings = {
    python = {
      analysis = {
        -- Automatically adds common subdirectories (like 'src') to the import path.
        autoSearchPaths = true,

        -- DIAGNOSTIC_MODE:
        -- 'workspace' checks every file in your project for errors, even if they aren't open.
        -- 'openFilesOnly' is faster but won't show errors in other files until you open them.
        diagnosticMode = "workspace",

        -- Allows Pyright to "peek" into your installed packages (pandas, numpy, etc.)
        -- to provide better autocompletion and type hints.
        useLibraryCodeForTypes = true,

        -- TYPE_CHECKING_MODE:
        -- 'basic' provides helpful hints without being too annoying.
        -- 'strict' will flag almost everything that isn't explicitly type-hinted.
        typeCheckingMode = "basic",
      },
    },
  },
}
