{pkgs, lib, config, ...}:

let
  inherit (lib) mkOption mkIf optionals literalExample;
  cfg = config.services.xserver.windowManager.xmonad;
  xmonad = cfg.haskellPackages.xmonad-with-packages.override {
    packages = self: cfg.extraPackages self ++
                     optionals cfg.enableContribAndExtras
                     [ self.xmonadContrib self.xmonadExtras ];
  };
in
{
  options = {
    services.xserver.windowManager.xmonad = {
      enable = mkOption {
        default = false;
        example = true;
        description = "Enable the xmonad window manager.";
      };

      haskellPackages = mkOption {
        default = pkgs.haskellPackages;
        defaultText = "pkgs.haskellPackages";
        example = literalExample "pkgs.haskellPackages_ghc701";
        description = ''
          haskellPackages used to build Xmonad and other packages.
          This can be used to change the GHC version used to build
          Xmonad and the packages listed in
          <varname>extraPackages</varname>.
        '';
      };

      extraPackages = mkOption {
        default = self: [];
        example = literalExample ''
          haskellPackages: [
            haskellPackages.xmonadContrib
            haskellPackages.monadLogger
          ]
        '';
        description = ''
          Extra packages available to ghc when rebuilding Xmonad. The
          value must be a function which receives the attrset defined
          in <varname>haskellpackages</varname> as the sole argument.
        '';
      };

      enableContribAndExtras = mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = "Enable xmonad-{contrib,extras} in Xmonad.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.xserver.windowManager = {
      session = [{
        name = "xmonad";
        start = ''
          ${xmonad}/bin/xmonad &
          waitPID=$!
        '';
      }];
    };

    environment.systemPackages = [ xmonad ];
  };
}
