# nixops-php-lumen

This is a simple project that I created to try understand NixOps - particularly how to package up a PHP project and deploy it onto a load balanced cluster.

There are some comments in the files, but as a rough overview this:
- Creates one backend that just serves a plain HTML file
- Creates one backend that serves a basic Lumen installation
- Creates a load balancing proxy in front of those, which roughly splits traffic equally between them when you hit the proxy's port 80
- I realise the load balancer doesn't really make sense when the two backends are completely different.

To get this working install NixOps (https://nixos.org/nixops) and VirtualBox (https://www.virtualbox.org, or https://nixos.wiki/wiki/Virtualbox on NixOS). To be honest the files I have here aren't really hugely different from the NixOps tutorial in the manual (https://nixos.org/nixops/manual/#idm140737322622464) - the key difference is the Lumen blog, which is packaged up in `blog.tar.gz` and specified in `lumen.nix`. To avoid repetition I would recommend following the manual for instructions on how to run this.

Nix[Ops/OS] don't have the best documentation, so hopefully this skeleton config will be helpful to someone.
