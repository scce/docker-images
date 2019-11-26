{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let connection = pkgs.lib.importJSON ../postgresql-connection.json;
    pgpassFileContent = ''
        ${connection.host}:${toString connection.port}:*:${connection.user}:${connection.password}
    '';
in pkgs.writeScriptBin "create-postgresql-database" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    readonly pgpass_file=$(${pkgs.coreutils}/bin/mktemp)
    trap '${pkgs.coreutils}/bin/rm "''${pgpass_file}"' EXIT
    ${pkgs.coreutils}/bin/echo -e "${pgpassFileContent}" > "''${pgpass_file}"
    ${pkgs.coreutils}/bin/chmod 600 "''${pgpass_file}"
    PGPASSFILE="''${pgpass_file}" ${pkgs.postgresql}/bin/createdb \
        --host="${connection.host}" \
        --port=${toString connection.port} \
        --user="${connection.user}" \
        --encoding=UTF8 \
        --lc-collate=C \
        --lc-ctype=C \
        --template=template0 \
        --owner="${connection.user}" \
        ${connection.database}
''
