{
  nixvim,
  lib,
  sharedPackages,
  devPackages,
  ...
}:
let
  helpers = import ../../lib.nix { packages = sharedPackages ++ devPackages; };
  inherit (helpers) hasDotnetSdk;
  useOmnisharp = nixvim.dotnet.useOmnisharp or false;
in
{
  programs.nixvim.lsp.servers = lib.mkIf useOmnisharp {
    omnisharp = {
      enable = lib.mkDefault hasDotnetSdk;
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
  };
}
