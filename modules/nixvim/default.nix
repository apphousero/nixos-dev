{
  pkgs,
  sharedPackages,
  devPackages,
  ...
}:
let
  helpers = import ../lib.nix { packages = sharedPackages ++ devPackages; };
  inherit (helpers) hasDotnetSdk hasNodejs;
in
{
  imports = [
    ./colorschemes.nix
    ./globals.nix
    ./keymaps.nix
    ./lua.nix
    ./opts.nix
    ./mini
    ./plugins
  ];
  programs.nixvim = {
    enable = true;
    # Pin nixvim's nixpkgs to the same source used to build this system.
    # This suppresses the `programs.nixvim.nixpkgs.source` follows warning and
    # gives the generated `options.json` a properly-contexted store reference
    # for downstream consumers that set `inputs.nixvim.inputs.nixpkgs.follows`.
    nixpkgs.source = pkgs.path;
    version.enableNixpkgsReleaseCheck = false;
    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [
          "cs"
          "csproj"
        ];
        command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab";
      }
      {
        event = [ "FileType" ];
        pattern = [ "nix" ];
        command = "setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab";
      }
    ];
    filetype.extension = {
      props = "csproj";
    };
    extraConfigVim = ''
      command! W w
    '';
    extraPackages =
      with pkgs;
      [
        gcc
        nil
      ]
      ++ lib.lists.optionals hasDotnetSdk [
        dotnetCorePackages.sdk_10_0
        netcoredbg
        omnisharp-roslyn
      ]
      ++ lib.lists.optionals hasNodejs [
        nodejs
        prettier
        vscode-langservers-extracted
        vscode-js-debug
      ];
  };
}
