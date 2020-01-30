let
  # The first backend is just a simple web page
  backend1 =
    { config, pkgs, ... }:
    {
      # Create a simple apache service and write out the web page
      services.httpd = {
        enable = true;
        adminAddr = "elishahastings@capuk.org";
        documentRoot = pkgs.writeTextDir "index.html" "Hello world! This is backend 1";
      };

      # Make sure we can access it
      networking.firewall.allowedTCPPorts = [ 22 80 ];
    };

  # The second backend imports a lumen blog and sets up a host for it on port 8000
  backend2 =
    { pkgs, ... }:
    # Import the lumen blog
    let lumenTestbed = import ./lumen.nix;
    in
    {
      # Install the lumen blog and php
      environment.systemPackages = [ lumenTestbed pkgs.php72 ];

      # Enable a systemd service that runs a PHP server for the blog
      systemd.services.lumenTestbed = {
        enable = true;
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          User = "root";
          WorkingDirectory = "${lumenTestbed}/blog";
          ExecStart = ''${pkgs.php72}/bin/php -S 0.0.0.0:8000 -t public'';
        };
      };

      # Open the firewall ports
      networking.firewall.allowedTCPPorts = [ 22 8000 ];
    };

in

{
  network.description = "Load balancing network";

  # Set up the proxy so we can actually load balance
  proxy =
    { config, pkgs, nodes, ... }:
    {
      services.httpd.enable = true;
      services.httpd.adminAddr = "elishahastings@capuk.org";
      services.httpd.extraModules = ["proxy_balancer" "lbmethod_byrequests"]; # Use byrequests so we balance equally
      services.httpd.extraConfig =
        ''
          <Proxy balancer://cluster>
            Allow from all
            BalancerMember http://backend1 retry=0
            # Forward to port 8000 as that's where PHP is running
            BalancerMember http://backend2:8000 retry=0
          </Proxy>
          ProxyPass         /    balancer://cluster/
          ProxyPassReverse  /    balancer://cluster/
        '';
      networking.firewall.allowedTCPPorts = [ 22 80 ];
    };

  # Use the config we've already created for the backends
  backend1 = backend1;
  backend2 = backend2;
}
