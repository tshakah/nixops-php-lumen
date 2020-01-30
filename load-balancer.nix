let

  backend1 =
    { config, pkgs, ... }:
    {
      services.httpd.enable = true;
      services.httpd.adminAddr = "elishahastings@capuk.org";
      services.httpd.documentRoot = pkgs.writeTextDir "index.html" "Hello world! This is backend 1";
      networking.firewall.allowedTCPPorts = [ 22 80 ];
    };

  backend2 =
    { config, pkgs, ... }:
    {
      services.httpd.enable = true;
      services.httpd.adminAddr = "elishahastings@capuk.org";
      services.httpd.documentRoot = pkgs.writeTextDir "index.html" "Hello world! This is backend 2";
      networking.firewall.allowedTCPPorts = [ 22 80 ];
    };

in

{
  network.description = "Load balancing network";

  proxy =
    { config, pkgs, nodes, ... }:
    { services.httpd.enable = true;
      services.httpd.adminAddr = "bob@example.org";
      services.httpd.extraModules = ["proxy_balancer" "lbmethod_byrequests"];
      services.httpd.extraConfig =
        ''
          <Proxy balancer://cluster>
            Allow from all
            BalancerMember http://backend1 retry=0
            BalancerMember http://backend2 retry=0
          </Proxy>
          ProxyPass         /    balancer://cluster/
          ProxyPassReverse  /    balancer://cluster/
        '';
      networking.firewall.allowedTCPPorts = [ 22 80 ];
    };

  backend1 = backend1;
  backend2 = backend2;
}
