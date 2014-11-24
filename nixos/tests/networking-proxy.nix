# Test whether `networking.proxy' work as expected.

import ./make-test.nix {
  name = "networking-proxy";

  nodes = {
    machine =
      { config, pkgs, ... }:

      {
        imports = [ ./common/user-account.nix ];

        networking.proxy.default = "http://user:pass@host:port";
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

    machine3 =
      { config, pkgs, ... }:

      {
        imports = [ ./common/user-account.nix ];

        networking.proxy = {
          # useless because overriden by the next options
          default = "http://user:pass@host:port";
          # advanced proxy setup
          http-proxy = "123-http://user:pass@http-host:port";
          https-proxy = "456-http://user:pass@https-host:port";
          rsync-proxy = "789-http://user:pass@rsync-host:port";
          ftp-proxy = "101112-http://user:pass@ftp-host:port";
          no-proxy = "131415-127.0.0.1,localhost,.localdomain";
        };

        services.xserver.enable = false;

        virtualisation.memorySize = 128;
      };
    };

  testScript =
    ''
      startAll;

      print $machine->execute("env | grep -i proxy");
      print $machine->execute("su - alice -c 'env | grep -i proxy'");
      $machine->mustSucceed("env | grep -i proxy");
      $machine->mustSucceed("su - alice -c 'env | grep -i proxy'");

      print $machine2->execute("env | grep -i proxy");
      print $machine2->execute("su - alice -c 'env | grep -i proxy'");
      $machine2->mustFail("env | grep -i proxy");
      $machine2->mustFail("su - alice -c 'env | grep -i proxy'");

      print $machine3->execute("env | grep -i proxy");
      print $machine3->execute("su - alice -c 'env | grep -i proxy'");
      $machine3->mustSucceed("env | grep -i http_proxy | grep 123");
      $machine3->mustSucceed("env | grep -i https_proxy | grep 456");
      $machine3->mustSucceed("env | grep -i rsync_proxy | grep 789");
      $machine3->mustSucceed("env | grep -i ftp_proxy | grep 101112");
      $machine3->mustSucceed("env | grep -i no_proxy | grep 131415");
      $machine3->mustSucceed("su - alice -c 'env | grep -i http_proxy | grep 123'");
      $machine3->mustSucceed("su - alice -c 'env | grep -i https_proxy | grep 456'");
      $machine3->mustSucceed("su - alice -c 'env | grep -i rsync_proxy | grep 789'");
      $machine3->mustSucceed("su - alice -c 'env | grep -i ftp_proxy | grep 101112'");
      $machine3->mustSucceed("su - alice -c 'env | grep -i no_proxy | grep 131415'");
    '';

}
