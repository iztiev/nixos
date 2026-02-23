{ inputs, config, pkgs, ... }:
{
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];

    environment.systemPackages = with pkgs; [
        age
        sops
    ];

    sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";

        defaultSopsFile = ../../secrets.yaml;
        validateSopsFiles = false;

        secrets = {
            iztiev-password = {};
            root-password = {};
            email-gmail = {
                owner = "iztiev";
                mode = "0400";
            };
            email-work = {
                owner = "iztiev";
                mode = "0400";
            };
            email-proton = {
                owner = "iztiev";
                mode = "0400";
            };
            "private_keys/id_dilcher" = {
                path = "/home/iztiev/.ssh/id_dilcher";
                owner = "iztiev";
                mode = "0400";
            };
            "private_keys/id_github" = {
                path = "/home/iztiev/.ssh/id_github";
                owner = "iztiev";
                mode = "0400";
            };
            "private_keys/id_hetzner" = {
                path = "/home/iztiev/.ssh/id_hetzner";
                owner = "iztiev";
                mode = "0400";
            };
            "private_keys/id_iztiev" = {
                path = "/home/iztiev/.ssh/id_iztiev";
                owner = "iztiev";
                mode = "0400";
            };
        };

        # Create git config file with secret email using template
        templates."gitconfig-email" = {
            owner = "iztiev";
            mode = "0400";
            path = "/home/iztiev/.config/git/config-email";
            content = ''
                [user]
                    email = ${config.sops.placeholder.email-gmail}
            '';
        };
    };
}