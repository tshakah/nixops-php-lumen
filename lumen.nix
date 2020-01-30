with (import <nixpkgs> {});
let
  # Create the testbed package
  lumenTestbed = (pkgs.stdenv.mkDerivation rec {
    pname = "lumen-testbed";
    version = "0.1.0";
    # Just use the tar in the same directory for the soruce. We could also use a remote link to do this, and verify the
    # tar's hash as well.
    src = ./blog.tar;
    # As we just need to unpack the tar file we only need the installPhase - if compilation etc was needed we might have
    # more
    phases = [ "installPhase" ];
    # The install phase takes the src tar (`$src`) and unpacks it to `$out` - this is a path in the nix store
    installPhase = ''
      mkdir $out
      tar -xvf $src -C $out
    '';
  });
in
  lumenTestbed
