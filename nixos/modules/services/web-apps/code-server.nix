{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.code-server;

in {
  ###### interface
  options = {
    services.code-server = {
      enable = mkEnableOption "enable code-server";

      package = mkOption {
        default = pkgs.code-server;
        defaultText = "pkgs.code-server";
        description = "Which code-server derivation to use";
        type = types.package;
      };

      packages = mkOption {
        default = [ ];
        defaultText = "[]";
        description = "Packages that are available in the PATH of code-server";
        example = "[ pkgs.go ]";
        type = types.listOf types.package;
      };

      host = mkOption {
        default = "127.0.0.1";
        defaultText = "Locahost-IP";
        description = "The host-ip to bind to";
        type = types.str;
      };

      port = mkOption {
        default = "4444";
        defaultText = "4444";
        description = "The port where code-server runs";
        type = types.str;
      };

      auth = mkOption {
        default = "password";
        defaultText = "Use password";
        description = "The type of authentication to use. [password, none]";
        type = types.str;
      };

      hashedPassword = mkOption {
        default = "";
        defaultText = "The hashed password, need auth set to 'password'";
        description = "Create the password with: 'echo -n 'thisismypassword' | npx argon2-cli -e'";
        type = types.str;
      };

      user = mkOption {
        default = "code-server";
        defaultText = "The internal code-server user";
        description = "Set the username for code-server. You can set this to your username to access your own files";
        type = types.str;
      };

      groups = mkOption {
        default = "[]";
        defaultText = "[]";
        description = "An array of additional groups for the code-server user";
        example = ''[ "docker" ]'';
        type = types.listOf types.str;
      };

    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.code-server = let

    in {
      description = "VSCode server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = cfg.packages;
      environment = {
        HASHED_PASSWORD = "${cfg.hashedPassword}";
        PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
      };
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/code-server --disable-telemetry --bind-addr ${cfg.host}:${cfg.port} --auth ${cfg.auth}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        RuntimeDirectory = "${cfg.package}";
        User = "${cfg.user}";
        Restart = "on-failure";
        # for ping probes
        AmbientCapabilities = [ "CAP_NET_RAW" ];

      };

    };

    users.users.code-server =
      mkIf (cfg.user == "code-server") {
        isNormalUser = true;
        createHome = true;
        description = "code-server user";
        home = "/home/code-server";
        extraGroups = cfg.groups;
        shell = pkgs.zsh;
      };
  };
}
