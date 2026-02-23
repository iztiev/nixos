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
            nexus-login = {
                owner = "iztiev";
                mode = "0400";
            };
            nexus-password = {
                owner = "iztiev";
                mode = "0400";
            };
            nexus-npm-auth = {
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

        # Create .netrc file with nexus credentials
        templates."netrc" = {
            owner = "iztiev";
            mode = "0600";
            path = "/home/iztiev/.netrc";
            content = ''
                machine nexus.env.liquidvu.com
                	login ${config.sops.placeholder.nexus-login}
                	password ${config.sops.placeholder.nexus-password}
            '';
        };

        # Create .npmrc file with nexus registry
        templates."npmrc" = {
            owner = "iztiev";
            mode = "0600";
            path = "/home/iztiev/.npmrc";
            content = ''
                registry=https://nexus.env.liquidvu.com/repository/npm-all/
                email=${config.sops.placeholder.email-work}
                always-auth=true
                //nexus.env.liquidvu.com/repository/npm-all/:_auth=${config.sops.placeholder.nexus-npm-auth}
            '';
        };

        # Create pip.conf file with nexus pypi registry
        templates."pip-conf" = {
            owner = "iztiev";
            mode = "0600";
            path = "/home/iztiev/.config/pip/pip.conf";
            content = ''
                [global]
                index = https://nexus.env.liquidvu.com/repository/pypi-all/pypi
                index-url = https://nexus.env.liquidvu.com/repository/pypi-all/simple
                keyring-provider = subprocess
            '';
        };
    };
}