import os
import subprocess
from random import Random

from workbench.database import open_database_connection, wait_for_database_connection
from workbench.dump import create_database_dump, compare_database_dumps
from workbench.seed import resolve_seed, generate_test_data, create_test_database, build_faker, create_directory, \
    generate_directory

docker_compose = ['docker-compose']
stop = docker_compose + ['stop']
rm_f = docker_compose + ['rm', '-f']
up_d = docker_compose + ['up', '-d']
run_backup = docker_compose + ['run', '--rm', 'backup']


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
    postgres_container = 'postgres'
    __run_command(stop + [postgres_container], verbose)
    __run_command(rm_f + [postgres_container], verbose)
    __run_command(up_d + [postgres_container], verbose)
    wait_for_database_connection()


def backup(verbose):
    __run_command(run_backup + ['--backup'], verbose)


def seed_db(seed):
    seed = resolve_seed(seed)
    tables = generate_test_data(seed)
    connection = open_database_connection()
    cursor = connection.cursor()
    create_test_database(cursor, tables)
    connection.commit()
    connection.close()


def seed_fs(seed):
    for directory in ["data", "dywa-app-logs"]:
        location = f"test/wildfly/{directory}"
        seed = resolve_seed(seed)
        random = Random(seed)
        faker = build_faker(seed)
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

    seed_db(seed)

    before = create_database_dump()
    backup(verbose)

    clean_db(verbose)

    restore(verbose, True)
    after = create_database_dump()

    passed = compare_database_dumps(before, after)

    message = "failed"
    exit_code = 1
    if passed:
        exit_code = 0
        message = "passed"

    print("Test %s" % message)
    exit(exit_code)


def __run_command(command, verbose):
    stdout = subprocess.PIPE
    stderr = subprocess.PIPE
    if verbose:
        stdout = None
        stderr = None
    subprocess.run(command, stdout=stdout, stderr=stderr)
