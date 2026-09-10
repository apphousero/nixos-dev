{ pkgs }:

pkgs.mistral-vibe.overrideAttrs (_: {
  doCheck = false;
  doInstallCheck = false;
})
