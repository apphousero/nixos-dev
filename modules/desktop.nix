{ lib, pkgs, ... }:
{
  imports = [
    ./development.nix
  ];

  console = {
    earlySetup = true;
    font = lib.mkDefault "ter-v16n";
    keyMap = lib.mkDefault "us";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = lib.mkDefault true;
  };

  fonts = {
    packages = with pkgs; [
      dina-font
      fira-code
      fira-code-symbols
      font-awesome
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      proggyfonts
      terminus_font
    ];
  };

  environment.systemPackages = with pkgs; [
    # terminals
    alacritty
    foot
    kitty
    # browsers
    brave
    chromium
    firefox
  ];
}
