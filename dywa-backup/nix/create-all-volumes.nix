{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let create-postgresql-volume = import ./create-postgresql-volume.nix { inherit pkgs volumesPath; };
    create-wildfly-volume = import ./create-wildfly-volume.nix { inherit pkgs volumesPath; };
in pkgs.writeScriptBin "create-all-volumes" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    mkdir -p "${volumesPath}/"{supervisord,postgresql-socket,restic-repository,wildfly}
    ${create-postgresql-volume}/bin/create-postgresql-volume
    touch "${volumesPath}/dywa-backup-volumes-safety-marker"
''
