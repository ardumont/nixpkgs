# /etc files related to networking, such as /etc/services.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.networking;
  dnsmasqResolve = config.services.dnsmasq.enable &&
                   config.services.dnsmasq.resolveLocalQueries;
  hasLocalResolver = config.services.bind.enable || dnsmasqResolve;

in

{

  options = {

    networking.extraHosts = lib.mkOption {
      type = types.lines;
      default = "";
      example = "192.168.0.1 lanlocalhost";
      description = ''
        Additional entries to be appended to <filename>/etc/hosts</filename>.
      '';
    };

    networking.dnsSingleRequest = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Recent versions of glibc will issue both ipv4 (A) and ipv6 (AAAA)
        address queries at the same time, from the same port. Sometimes upstream
        routers will systemically drop the ipv4 queries. The symptom of this problem is
        that 'getent hosts example.com' only returns ipv6 (or perhaps only ipv4) addresses. The
        workaround for this is to specify the option 'single-request' in
        /etc/resolv.conf. This option enables that.
      '';
    };

    networking.proxy = {

      default = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the *_proxy for the users in the environment.
          It is exporting the http_proxy, https_proxy, ftp_proxy, rsync_proxy
          with that value.
          You can also define a dedicated http-proxy, https-proxy, ftp-proxy, rsync-proxy or no-proxy.
        '';
        example = "http://127.0.0.1:3128";
      };

      http-proxy = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the http_proxy for the users in the environment.
          It is just exporting the http_proxy with that value.
        '';
        example = "http://127.0.0.1:3128";
      };

      https-proxy = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the https_proxy for the users in the environment.
          It is just exporting the https_proxy with that value.
        '';
        example = "http://127.0.0.1:3128";
      };

      ftp-proxy = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the ftp_proxy for the users in the environment.
          It is just exporting the ftp_proxy with that value.
        '';
        example = "http://127.0.0.1:3128";
      };

      rsync-proxy = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the rsync_proxy for the users in the environment.
          It is just exporting the rsync_proxy with that value.
        '';
        example = "http://127.0.0.1:3128";
      };

      no-proxy = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          This option specifies the no_proxy for the users in the environment.
          It is just exporting the no_proxy with that value.
        '';
        example = "127.0.0.1,localhost,.localdomain";
      };

      envVars = lib.mkOption {
        type = types.attrs;
        internal = true;
        default = {};
        description = ''
          Environment variables used by networking (was specifically open for networking.proxy.*).
          If you want to specify environment variables, use `nix.envVars`.
        '';
      };
    };

  };

  config = {

    environment.etc =
      { # /etc/services: TCP/UDP port assignments.
        "services".source = pkgs.iana_etc + "/etc/services";

        # /etc/protocols: IP protocol numbers.
        "protocols".source  = pkgs.iana_etc + "/etc/protocols";

        # /etc/rpc: RPC program numbers.
        "rpc".source = pkgs.glibc + "/etc/rpc";

        # /etc/hosts: Hostname-to-IP mappings.
        "hosts".text =
          ''
            127.0.0.1 localhost
            ${optionalString cfg.enableIPv6 ''
              ::1 localhost
            ''}
            ${cfg.extraHosts}
          '';

        # /etc/resolvconf.conf: Configuration for openresolv.
        "resolvconf.conf".text =
            ''
              # This is the default, but we must set it here to prevent
              # a collision with an apparently unrelated environment
              # variable with the same name exported by dhcpcd.
              interface_order='lo lo[0-9]*'
            '' + optionalString config.services.nscd.enable ''
              # Invalidate the nscd cache whenever resolv.conf is
              # regenerated.
              libc_restart='${pkgs.systemd}/bin/systemctl try-restart --no-block nscd.service'
            '' + optionalString cfg.dnsSingleRequest ''
              # only send one DNS request at a time
              resolv_conf_options='single-request'
            '' + optionalString hasLocalResolver ''
              # This hosts runs a full-blown DNS resolver.
              name_servers='127.0.0.1'
            '' + optionalString dnsmasqResolve ''
              dnsmasq_conf=/etc/dnsmasq-conf.conf
              dnsmasq_resolv=/etc/dnsmasq-resolv.conf
            '';
      };

      networking.proxy.envVars =
        optionalAttrs (cfg.proxy.default != "") {
          http_proxy = cfg.proxy.default;
          https_proxy = cfg.proxy.default;
          rsync_proxy = cfg.proxy.default;
          ftp_proxy = cfg.proxy.default;
          no_proxy = "127.0.0.1,localhost";
        } // optionalAttrs (cfg.proxy.http-proxy != "") {
          http_proxy  = cfg.proxy.http-proxy;
        } // optionalAttrs (cfg.proxy.https-proxy != "") {
          https_proxy = cfg.proxy.https-proxy;
        } // optionalAttrs (cfg.proxy.rsync-proxy != "") {
          rsync_proxy = cfg.proxy.rsync-proxy;
        } // optionalAttrs (cfg.proxy.ftp-proxy != "") {
          ftp_proxy   = cfg.proxy.ftp-proxy;
        } // optionalAttrs (cfg.proxy.no-proxy != "") {
          no_proxy    = cfg.proxy.no-proxy;
        };

    # The ‘ip-up’ target is started when we have IP connectivity.  So
    # services that depend on IP connectivity (like ntpd) should be
    # pulled in by this target.
    systemd.targets.ip-up.description = "Services Requiring IP Connectivity";
  };

  }
