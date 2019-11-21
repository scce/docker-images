{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let supervisord-conf = import ./supervisord-conf.nix { inherit pkgs volumesPath; };
in pkgs.writeScriptBin "run-supervisord" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${pkgs.python3Packages.supervisor}/bin/supervisord -c ${supervisord-conf} "$@"
''
