{ config, lib, pkgs, ... }:

with lib;
let

  cfg = config.services.code-server;
  defaultUser = "code-server";
  defaultGroup = defaultUser;

in {
  ###### interface
  options = {
    services.code-server = {
      enable = mkEnableOption "code-server";

      package = mkOption {
        default = pkgs.code-server;
        defaultText = "pkgs.code-server";
        description = "Which code-server derivation to use.";
        type = types.package;
      };

      packages = mkOption {
        default = [ ];
        defaultText = "[]";
        description = "Packages that are available in the PATH of code-server.";
        example = "[ pkgs.go ]";
        type = types.listOf types.package;
      };

      extra-environment = mkOption {
        type = types.attrsOf types.str;
        description =
          "Additional environment variables to passed to code-server.";
        default = { };
        example = { PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig"; };
      };

      host = mkOption {
        default = "127.0.0.1";
        description = "The host-ip to bind to.";
        type = types.str;
      };

      port = mkOption {
        default = 4444;
        description = "The port where code-server runs.";
        type = types.port;
      };

      auth = mkOption {
        default = "password";
        description = "The type of authentication to use.";
        type = types.enum [ "none" "password" ];
      };

      hashedPassword = mkOption {
        default = "";
        description =
          "Create the password with: 'echo -n 'thisismypassword' | npx argon2-cli -e'.";
        type = types.str;
      };

      user = mkOption {
        default = defaultUser;
        example = "yourUser";
        description = ''
          The user to run Syncthing as.
          By default, a user named <literal>${defaultUser}</literal> will be created.
        '';
        type = types.str;
      };

      group = mkOption {
        default = defaultGroup;
        example = "yourGroup";
        description = ''
          The group to run code-server under.
          By default, a group named <literal>${defaultGroup}</literal> will be created.
        '';
        type = types.str;
      };

      groups = mkOption {
        default = [ ];
        defaultText = "[]";
        description =
          "An array of additional groups for the <literal>${defaultUser}</literal> user.";
        example = [ "docker" ];
        type = types.listOf types.str;
      };

    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.code-server = {
      description = "VSCode server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = cfg.packages;
      environment = {
        HASHED_PASSWORD = cfg.hashedPassword;
      } // cfg.extra-environment;
      serviceConfig = {
        ExecStart =
          "${cfg.package}/bin/code-server --disable-telemetry --bind-addr ${cfg.host}:${
            toString cfg.port
          } --auth ${cfg.auth}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        RuntimeDirectory = cfg.user;
        User = cfg.user;
        Restart = "on-failure";
      };

    };

    users.users."${defaultUser}" = mkIf (cfg.user == defaultUser) {
      isNormalUser = true;
      group = cfg.group;
      extraGroups = cfg.groups;
      description = "code-server user";
      shell = pkgs.bash;
    };

    users.groups."${defaultGroup}" = mkIf (cfg.group == defaultGroup) { };

  };
}
