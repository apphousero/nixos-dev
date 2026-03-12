{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Helper function to check if a package is available (works in both NixOS and home-manager)
  packages =
    (if config ? environment then config.environment.systemPackages or [ ] else [ ])
    ++ (if config ? home then config.home.packages or [ ] else [ ]);
  hasPackage = pkg: builtins.any (p: p.pname or p.name or "" == pkg) packages;
  # Language server availability checks
  hasDotnetSdk = hasPackage "dotnet" || hasPackage "dotnet-sdk" || hasPackage "dotnet-sdk-wrapped";
  hasNodejs = hasPackage "nodejs";
  hasPython = hasPackage "python3";
  hasGo = hasPackage "go";
  hasJava = hasPackage "openjdk" || hasPackage "jdk";
in
{
  programs.nixvim.plugins = {
    lsp.enable = true;
  };
  programs.nixvim.lsp = {
    enable = true;
    keymaps = [
      {
        key = "gd";
        lspBufAction = "definition";
      }
      {
        key = "gD";
        lspBufAction = "references";
      }
      {
        key = "gt";
        lspBufAction = "type_definition";
      }
      {
        key = "gi";
        lspBufAction = "implementation";
      }
      {
        key = "<leader>K";
        lspBufAction = "hover";
      }
      {
        action.__raw = "function() vim.diagnostic.jump({ count=-1, float=true }) end";
        key = "<leader>k";
      }
      {
        action.__raw = "function() vim.diagnostic.jump({ count=1, float=true }) end";
        key = "<leader>j";
      }
      {
        action = "<CMD>LspStop<Enter>";
        key = "<leader>lx";
      }
      {
        action = "<CMD>LspStart<Enter>";
        key = "<leader>ls";
      }
      {
        action = "<CMD>LspRestart<Enter>";
        key = "<leader>lr";
      }
      {
        action.__raw = "require('telescope.builtin').lsp_definitions";
        key = "gd";
      }
      {
        action = "<CMD>LspInfo<Enter>";
        key = "<leader>li";
      }
    ];
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cssls.enable = lib.mkDefault hasNodejs;
      csharp_ls = {
        enable = lib.mkDefault hasDotnetSdk;
      };
      dockerls.enable = true;
      eslint.enable = lib.mkDefault hasNodejs;
      gopls = {
        enable = lib.mkDefault hasGo;
        config = {
          gofumpt = true;
          staticcheck = true;
          usePlaceholders = true;
        };
      };
      html.enable = lib.mkDefault hasNodejs;
      htmx.enable = lib.mkDefault hasNodejs;
      java_language_server.enable = lib.mkDefault hasJava;
      jsonls.enable = true;
      lua_ls.enable = true;
      marksman.enable = true;
      nil_ls = {
        enable = true;
        config = {
          autoArchive = true;
        };
      };
      omnisharp = {
        # enable = lib.mkDefault hasDotnetSdk;
        enable = false;
        config = {
          settings = {
            RoslynExtensionsOptions = {
              documentAnalysisTimeoutMs = 30000;
              enableDecompilationSupport = true;
              enableImportCompletion = true;
              enableAnalyzersSupport = true;
              diagnosticWorkersThreadCount = 8;
              locationPaths = [ ];
              inlayHintsOptions = {
                enableForParameters = true;
                forLiteralParameters = true;
                forIndexerParameters = true;
                forObjectCreationParameters = true;
                forOtherParameters = true;
                suppressForParametersThatDifferOnlyBySuffix = false;
                suppressForParametersThatMatchMethodIntent = false;
                suppressForParametersThatMatchArgumentName = false;
                enableForTypes = true;
                forImplicitVariableTypes = true;
                forLambdaParameterTypes = true;
                forImplicitObjectCreation = true;
              };
            };
            FormattingOptions = {
              EnableEditorConfigSupport = false;
              OrganizeImports = false;
              NewLine = "\n";
              UseTabs = false;
              TabSize = 4;
              IndentationSize = 4;
              SpacingAfterMethodDeclarationName = false;
              SpaceWithinMethodDeclarationParenthesis = false;
              SpaceBetweenEmptyMethodDeclarationParentheses = false;
              SpaceAfterMethodCallName = false;
              SpaceWithinMethodCallParentheses = false;
              SpaceBetweenEmptyMethodCallParentheses = false;
              SpaceAfterControlFlowStatementKeyword = true;
              SpaceWithinExpressionParentheses = false;
              SpaceWithinCastParentheses = false;
              SpaceWithinOtherParentheses = false;
              SpaceAfterCast = false;
              SpacesIgnoreAroundVariableDeclaration = false;
              SpaceBeforeOpenSquareBracket = false;
              SpaceBetweenEmptySquareBrackets = false;
              SpaceWithinSquareBrackets = false;
              SpaceAfterColonInBaseTypeDeclaration = true;
              SpaceAfterComma = true;
              SpaceAfterDot = false;
              SpaceAfterSemicolonsInForStatement = true;
              SpaceBeforeColonInBaseTypeDeclaration = true;
              SpaceBeforeComma = false;
              SpaceBeforeDot = false;
              SpaceBeforeSemicolonsInForStatement = false;
              SpacingAroundBinaryOperator = "single";
              IndentBraces = false;
              IndentBlock = true;
              IndentSwitchSection = true;
              IndentSwitchCaseSection = true;
              IndentSwitchCaseSectionWhenBlock = true;
              LabelPositioning = "oneLess";
              WrappingPreserveSingleLine = true;
              WrappingKeepStatementsOnSingleLine = true;
              NewLinesForBracesInTypes = true;
              NewLinesForBracesInMethods = true;
              NewLinesForBracesInProperties = true;
              NewLinesForBracesInAccessors = true;
              NewLinesForBracesInAnonymousMethods = true;
              NewLinesForBracesInControlBlocks = true;
              NewLinesForBracesInAnonymousTypes = true;
              NewLinesForBracesInObjectCollectionArrayInitializers = true;
              NewLinesForBracesInLambdaExpressionBody = true;
              NewLineForElse = true;
              NewLineForCatch = true;
              NewLineForFinally = true;
              NewLineForMembersInObjectInit = true;
              NewLineForMembersInAnonymousTypes = true;
              NewLineForClausesInQuery = true;
            };
            RenameOptions = {
              RenameInComments = false;
              RenameOverloads = false;
              RenameInStrings = false;
            };
            Sdk = {
              IncludePrereleases = false;
            };
            enableRoslynAnalyzers = true;
            enableSemanticHighlighting = true;
          };
        };
      };
      pylsp = {
        enable = lib.mkDefault hasPython;
        config = {
          plugins = {
            pycodestyle.enabled = false;
            mccabe.enabled = false;
            pyflakes.enabled = false;
            flake8.enabled = true;
            autopep8.enabled = false;
            yapf.enabled = false;
            black.enabled = true;
            isort.enabled = true;
            mypy.enabled = true;
          };
        };
      };
      sqls.enable = true;
      ts_ls.enable = lib.mkDefault hasNodejs;
      #tsserver.enable = lib.mkDefault hasNodejs;
      yamlls.enable = true;
    };
  };
  programs.nixvim.plugins = {
    lsp-format.enable = true;
    trouble = {
      enable = true;
      settings = {
        auto_open = false;
        auto_close = true;
      };
    };
  };
}
