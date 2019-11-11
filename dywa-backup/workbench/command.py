import os
from random import randint, Random

import psycopg2
from dotenv import dotenv_values
from faker import Faker

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


def generate_test_data(seed):
    random = Random(seed)
    faker = build_faker(seed)
    return [
        generate_table(random, faker)
        for i in range(random.randint(0, 10))
    ]


def generate_table(random, faker):
    column_types = [
        "text",
        "integer",
        "boolean",
        "real",
    ]
    fakers = {
        "text": faker.name,
        "integer": faker.pyint,
        "boolean": faker.pybool,
        "real": faker.pyfloat,
    }
    column_headers = [{"type": "integer", "name": "id"}] + [
        {
            "type": random.choice(column_types),
            "name": postgresql_identifier(random),
        }
        for j in range(1, random.randint(1, 10))
    ]
    rows = [
        [fakers[header["type"]]() for header in column_headers]
        for k in range(random.randint(0, 10))
    ]
    return {
        "name": postgresql_identifier(random),
        "column_headers": column_headers,
        "rows": rows,
    }


def postgresql_identifier(random):
    return generate_identifier(
        random,
        list("abcdefghijklmnopqrstuvwxyz_"),
    )


def open_database_connection():
    config = dotenv_values()
    return psycopg2.connect(
        host=config["POSTGRES_HOST"],
        port=config["POSTGRES_PORT"],
        dbname=config["POSTGRES_DB"],
        user=config["POSTGRES_USER"],
        password=config["POSTGRES_PASSWORD"]
    )


def create_test_database(cursor, tables):
    for table in tables:
        columns_statement = ", ".join([
            f"{header['name']} {header['type']}"
            for header in table["column_headers"]
        ])
        table_statement = f"create table {table['name']} ({columns_statement});"
        cursor.execute(table_statement)
        for row in table["rows"]:
            values_statement = ", ".join(["%s"] * len(row))
            insert_statement = (
                f"insert into {table['name']} values ({values_statement});"
            )
            cursor.execute(insert_statement, row)


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


def generate_directory(random, faker, probability):
    return {
        "files": {
            generate_file_identifier(random): faker.paragraph()
            for j in range(random.randint(0, 10))
        },
        "children": {
            generate_file_identifier(random):
                generate_directory(random, faker, probability / 2)
            for i in range(random.randint(0, 4))
        } if random.random() < probability else {},
    }


def generate_file_identifier(random):
    return generate_identifier(
        random,
        [chr(i) for i in range(32, 127) if chr(i) != "/"],
    )


def create_directory(location, directory):
    for name, content in directory["files"].items():
        with open(f"{location}/{name}", "w") as file:
            file.write(content)
    for name, child in directory["children"].items():
        child_location = f"{location}/{name}"
        os.mkdir(child_location)
        create_directory(child_location, child)


def resolve_seed(args):
    seed = args.seed if args.seed is not None else randint(0, 999999)
    print(f"Seed: {seed}")
    return seed


def generate_identifier(random, alphabet):
    return "".join(
        random.choice(alphabet)
        for _ in range(random.randint(5, 20))
    )


def build_faker(seed):
    faker = Faker("de_DE")
    faker.seed(seed)
    return faker
