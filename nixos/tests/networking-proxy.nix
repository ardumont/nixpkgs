# Test whether `networking.proxy' work as expected.

import ./make-test.nix {
  name = "networking-proxy";

  nodes = {
    machine =
      { config, pkgs, ... }:

      {
        imports = [ ./common/user-account.nix ];

        networking.proxy = "http://user:pass@host:port";
        services.xserver.enable = false;

        virtualisation.memorySize = 128;
      };

    machine2 =
      { config, pkgs, ... }:

      {
        imports = [ ./common/user-account.nix ];

        services.xserver.enable = false;

        virtualisation.memorySize = 128;
      };
    };

  testScript =
    ''
      startAll;

      $machine->sleep(10);
      print $machine->execute("env | grep -i proxy");
      print $machine->execute("su - alice -c 'env | grep -i proxy'");
      $machine->mustSucceed("env | grep -i proxy");
      $machine->mustSucceed("su - alice -c 'env | grep -i proxy'");

      print $machine2->execute("env | grep -i proxy");
      print $machine2->execute("su - alice -c 'env | grep -i proxy'");
      $machine2->mustFail("env | grep -i proxy");
      $machine2->mustFail("su - alice -c 'env | grep -i proxy'");
    '';

}
