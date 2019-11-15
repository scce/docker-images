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


def check(args):
    __run_command(run_backup + ['--check'], args.verbose)


def init(args):
    __run_command(run_backup + ['--init'], args.verbose)


def restore(args):
    __run_command(run_backup + ['--restore', 'latest', '-y'], args.verbose)


def up(args):
    __run_command(docker_compose + ['up'], args.verbose)


def clean_db(args):
    postgres_container = 'postgres'
    __run_command(stop + [postgres_container], args.verbose)
    __run_command(rm_f + [postgres_container], args.verbose)
    __run_command(up_d + [postgres_container], args.verbose)
    wait_for_database_connection()


def backup(args):
    __run_command(run_backup + ['--backup'], args.verbose)


def seed_db(args):
    seed = resolve_seed(args)
    tables = generate_test_data(seed)
    connection = open_database_connection()
    cursor = connection.cursor()
    create_test_database(cursor, tables)
    connection.commit()
    connection.close()


def seed_fs(args):
    for directory in ["data", "dywa-app-logs"]:
        location = f"test/wildfly/{directory}"
        seed = resolve_seed(args)
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


def test(args):
    init(args)

    clean_db(args)

    seed_db(args)

    before = create_database_dump()
    backup(args)

    clean_db(args)

    restore(args)
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
