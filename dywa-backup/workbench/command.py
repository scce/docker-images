import os
import subprocess
from random import Random
import os.path
import shutil

from workbench.database import open_database_connection, wait_for_database_connection
from workbench.dump import create_database_dump, compare_database_dumps, create_filesystem_dump, \
    compare_filesystem_dumps
from workbench.seed import resolve_seed, generate_test_data, create_test_database, build_faker, create_directory, \
    generate_directory

docker_compose = ['docker-compose']
run_backup = docker_compose + ['run', '--rm', 'backup']
volumes_path = "volumes"
wildfly_volume = "volumes/wildfly"


def check(verbose):
    __run_command(run_backup + ['--check'], verbose)


def init(verbose):
    __run_command(run_backup + ['--init'], verbose)


def restore(verbose, yes=False):
    command = run_backup + ['--restore', 'latest']
    if yes:
        command = command + ['-y']
    __run_command(command, verbose)


def up(verbose):
    __run_command(docker_compose + ['up'], verbose)


def clean_db(verbose):
    __run_command(["run-supervisorctl", "stop",  "postgresql"], verbose)
    remove_volume("postgresql")
    __run_command(["create-postgresql-volume"], verbose)
    __run_command(["run-supervisorctl", "start", "postgresql"], verbose)
    wait_for_database_connection()
    __run_command(["create-postgresql-database"], verbose)


def clean_fs(verbose):
    remove_volume("wildfly", recreate=True)


def backup(verbose):
    __run_command(run_backup + ['--backup'], verbose)


def seed_db(verbose, seed):
    seed = resolve_seed(verbose, seed)
    tables = generate_test_data(seed)
    connection = open_database_connection()
    cursor = connection.cursor()
    create_test_database(cursor, tables)
    connection.commit()
    connection.close()


def seed_fs(verbose, seed):
    seed = resolve_seed(verbose, seed)
    random = Random(seed)
    faker = build_faker(seed)
    for location in __generate_wildfly_data_directories():
        try:
            os.mkdir(location)
        except FileExistsError:
            pass
        create_directory(
            location,
            generate_directory(random, faker, 1.0)
        )


def test(verbose, seed):
    init(verbose)

    clean_db(verbose)
    clean_fs(verbose)

    seed = resolve_seed(verbose, seed)
    seed_db(False, seed)
    seed_fs(False, seed)

    database_before = create_database_dump()
    filesystem_before = create_filesystem_dump(wildfly_volume)
    backup(verbose)

    clean_db(verbose)
    clean_fs(verbose)

    restore(verbose, True)
    database_after = create_database_dump()
    filesystem_after = create_filesystem_dump(wildfly_volume)

    passed = compare_database_dumps(
        database_before,
        database_after
    ) and compare_filesystem_dumps(
        filesystem_before,
        filesystem_after
    )

    message = "failed"
    exit_code = 1
    if passed:
        exit_code = 0
        message = "passed"

    print("Test %s" % message)
    exit(exit_code)


def __generate_wildfly_data_directories():
    return map(
        lambda directory: f"{wildfly_volume}/{directory}",
        ["data", "dywa-app-logs"]
    )


def __run_command(command, verbose):
    stdout = subprocess.PIPE
    stderr = subprocess.PIPE
    if verbose:
        stdout = None
        stderr = None
    subprocess.run(command, stdout=stdout, stderr=stderr)


def remove_volume(service, recreate=False):
    if not os.path.isfile(f"{volumes_path}/dywa-backup-volumes-safety-marker"):
        raise Exception(
            "Unsafe file removal, missing marker file "
            "dywa-backup-volumes-safety-marker."
        )
    volume_path = f"{volumes_path}/{service}"
    shutil.rmtree(volume_path)
    if recreate:
        os.mkdir(volume_path)
