{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let postgresqlConnection = pkgs.lib.importJSON ../postgresql-connection.json;
in pkgs.writeScriptBin "create-postgresql-volume" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    readonly postgres_volume="${volumesPath}/postgresql"
    mkdir --mode 700 "''${postgres_volume}"
    ${pkgs.postgresql}/bin/initdb \
        -D "''${postgres_volume}" \
        --username="${postgresqlConnection.user}" \
        --pwfile=<(echo "${postgresqlConnection.password}")
''
