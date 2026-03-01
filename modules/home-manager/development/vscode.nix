{ config, lib, pkgs, inputs, ... }: {
  options.development.vscode.enable = lib.mkEnableOption "VSCode editor";

  config = lib.mkIf config.development.vscode.enable {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ] ++ (with inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace; [
        mohsen1.prettify-json
        wholroyd.jinja
      ]);
      profiles.default.userSettings = {
        "editor.fontFamily" = "'Izosevka', monospace";
        "editor.fontSize" = 20;
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "'Izosevka'";
        "terminal.integrated.fontSize" = 20;
      };
      profiles.default.keybindings = [
        # Terminal: Ctrl+C = copy (not interrupt)
        {
          key = "ctrl+c";
          command = "workbench.action.terminal.copySelection";
          when = "terminalFocus && terminalHasBeenCreated";
        }
        # Terminal: Ctrl+Shift+C = interrupt (send ^C to process); remove default copy
        {
          key = "ctrl+shift+c";
          command = "-workbench.action.terminal.copySelection";
        }
        {
          key = "ctrl+shift+c";
          command = "workbench.action.terminal.sendSequence";
          args = { text = builtins.fromJSON ''"\u0003"''; };
          when = "terminalFocus";
        }
        # Terminal: Ctrl+V = paste
        {
          key = "ctrl+v";
          command = "workbench.action.terminal.paste";
          when = "terminalFocus && terminalHasBeenCreated";
        }
      ];
    };
  };
}
