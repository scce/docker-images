{ pkgs ? import <nixpkgs> {}
, volumesPath
}:
let postgresqlConnection = pkgs.lib.importJSON ../postgresql-connection.json;
    postgresqlConfigFile = pkgs.writeText "postgresql.conf" ''
        listen_addresses='${postgresqlConnection.host}'
        port=${toString postgresqlConnection.port}
        unix_socket_directories='${volumesPath}/postgresql-socket'
    '';
    postgresqlHBAFile = pkgs.writeText "pg_hba.conf" ''
        local all all              trust
        host  all all 127.0.0.1/32 password
        host  all all ::1/128      password
    '';
    user = "supervisor";
    password = "asdf";
in pkgs.writeText "supervisord-configuration" ''
    [supervisord]
    logfile=${volumesPath}/supervisord/supervisord.log
    pidfile=${volumesPath}/supervisord/supervisord.pid
    nodaemon=true
    [inet_http_server]
    port = 127.0.0.1:9001
    username = ${user}
    password = ${password}
    [supervisorctl]
    serverurl = http://localhost:9001
    username = ${user}
    password = ${password}
    [program:postgresql]
    command=${pkgs.postgresql}/bin/postgres -D "${volumesPath}/postgresql" --config_file="${postgresqlConfigFile}" --hba_file="${postgresqlHBAFile}"
    redirect_stderr=true
    stdout_logfile=/dev/stdout
    stdout_logfile_maxbytes = 0
    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
''
