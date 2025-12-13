{
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
  ];
  environment.systemPackages = with pkgs; [
    # Azure CLI... needed, not wanted
    #azure-cli
    # .NET SDK packages
    (
      with dotnetCorePackages;
      combinePackages [
        sdk_8_0
        sdk_9_0
        sdk_10_0
      ]
    )
    # Analyse docker images
    dive
    # Github CLI
    gh
    # GCP CLI
    google-cloud-sdk
    # and Gemini CLI
    gemini-cli
    # ping but with graph
    gping
    # kubectl and its relatives
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    k9s
    # lazy but for Docker
    lazydocker
    # lazy SQL
    lazysql
    # NodeJS
    nodejs_24
    nodejs_22
    #nodejs_20
    #nodejs_18
    nodePackages.node-gyp
    nodePackages.node-gyp-build
    # aaah, mermaid
    mermaid-cli
    # HTTP load generator
    oha
    # For certificates
    openssl
    # For docs
    pandoc
    python3Packages.virtualenv
    # something I need
    seq-cli
    (texlive.combine {
      inherit (texlive)
        scheme-basic
        latex-bin
        latexmk
        xcolor
        ;
    })
    # tldr any command instead of man, e.g. tldr fd
    tldr
    # TUI client for SQL
    usql
    # HTTP load testing tool
    vegeta
    # NodeJS package manager
    yarn
  ];
  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_8_0}";
    MC_SKIN = "dark";
  };
  #nixpkgs.config.permittedInsecurePackages = [
  #  "dotnet-sdk-6.0.428"
  #];
}
