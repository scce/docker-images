{ pkgs ? import <nixpkgs> {}
, volumesPath ? "${toString ./.}/volumes"
}:
pkgs.stdenv.mkDerivation {
    name = "dywa-backup-shell";
    buildInputs = [
        (pkgs.python3.withPackages (ps: with ps; [psycopg2 faker]))
        (import ./nix/create-all-volumes.nix {inherit pkgs volumesPath;})
        (import ./nix/create-postgresql-volume.nix {inherit pkgs volumesPath;})
        (import ./nix/run-supervisord.nix {inherit pkgs volumesPath;})
        (import ./nix/run-supervisorctl.nix {inherit pkgs volumesPath;})
        (import ./nix/create-postgresql-database.nix {inherit pkgs volumesPath;})
        pkgs.python3Packages.supervisor
        pkgs.restic
    ];
}
