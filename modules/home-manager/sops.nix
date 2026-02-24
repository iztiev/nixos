{ inputs, config, ... }:
{
    imports = [
        inputs.sops-nix.homeManager.sops
    ];

    sops = {
        age.keyFile = "/var/lib/sops-nix/key.txt";

        defaultSopsFile = ../../secrets.yaml;
        validateSopsFiles = false;

        secrets = {
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
            "email-work" = {
                path = "/run/secrets/email-work";
                owner = "iztiev";
                mode = "0400";
            };
            "email-gmail" = {
                path = "/run/secrets/email-gmail";
                owner = "iztiev";
                mode = "0400";
            };
            "email-proton" = {
                path = "/run/secrets/email-proton";
                owner = "iztiev";
                mode = "0400";
            };
        };
    };
}