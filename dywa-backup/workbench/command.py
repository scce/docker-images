import os
from random import Random

from workbench.database import open_database_connection
from workbench.seed import resolve_seed, generate_test_data, create_test_database, build_faker, create_directory, \
    generate_directory

docker_compose = 'docker-compose %s'
stop = docker_compose % 'stop %s'
rm_f = docker_compose % 'rm -f %s'
up_d = docker_compose % 'up -d %s'
run_backup = docker_compose % 'run --rm backup "--%s"'


def check():
    os.system(run_backup % 'check')


def init():
    os.system(run_backup % 'init')


def restore():
    os.system(run_backup % 'restore')


def up():
    os.system(docker_compose % 'up')


def clean_db():
    postgres_container = 'postgres'
    os.system(stop % postgres_container)
    os.system(rm_f % postgres_container)
    os.system(up_d % postgres_container)


def backup():
    os.system(run_backup % 'backup')


def seed_db(args):
    seed = resolve_seed(args)
    tables = generate_test_data(seed)
    connection = open_database_connection()
    cursor = connection.cursor()
    create_test_database(cursor, tables)
    connection.commit()
    connection.close()


def seed_fs(args):
    seed = resolve_seed(args)
    random = Random(seed)
    faker = build_faker(seed)
    location = "./test-directory"
    try:
        os.mkdir(location)
    except FileExistsError:
        pass
    create_directory(
        location,
        generate_directory(random, faker, 1.0)
    )
