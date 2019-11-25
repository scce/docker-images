{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let postgresqlConnection = pkgs.lib.importJSON ../postgresql-connection.json;
in pkgs.writeScriptBin "create-postgresql-database" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    ${pkgs.postgresql}/bin/createdb \
        --host="${volumesPath}/postgresql-socket" \
        --port=${toString postgresqlConnection.port} \
        --user="${postgresqlConnection.user}" \
        --encoding=UTF8 \
        --lc-collate=C \
        --lc-ctype=C \
        --template=template0 \
        --owner="${postgresqlConnection.user}" \
        ${postgresqlConnection.database}
''
