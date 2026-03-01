{ pkgs, ... }: {
  imports = [
    ./go.nix
    ./python.nix
    ./vscode.nix
    ./web.nix
  ];

  # Enable all by default
  development.go.enable = true;
  development.python.enable = true;
  development.vscode.enable = true;
  development.web.enable = true;

  home.packages = with pkgs; [
    claude-code

    # Build Tools
    gcc
  ];

  # ── Git ──
  programs.git = {
    enable = true;
    # user.email is set via sops template at ~/.config/git/config-email
    includes = [
      { path = "~/.config/git/config-email"; }
    ];
    settings = {
      user.name = "Timur Izmagambetov";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
