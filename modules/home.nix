{
  pkgs,
  sharedPackages,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # ── Packages (shared + home-only) ──────────────────────────────────────
  home.packages =
    sharedPackages
    ++ (with pkgs; [
      spotify-player
    ]);

  # ── Environment variables ───────────────────────────────────────────────
  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MC_SKIN = "dark";
  };
}
