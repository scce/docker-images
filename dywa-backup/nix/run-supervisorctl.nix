{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let supervisord-conf = import ./supervisord-conf.nix { inherit pkgs volumesPath; };
in pkgs.writeScriptBin "run-supervisorctl" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${pkgs.python3Packages.supervisor}/bin/supervisorctl -c ${supervisord-conf} "$@"
''
