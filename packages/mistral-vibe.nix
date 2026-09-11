{ pkgs }:

pkgs.mistral-vibe.overrideAttrs (_: {
  dontUsePytestCheck = true;
})
