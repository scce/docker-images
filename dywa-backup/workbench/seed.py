import os
from random import randint, Random

from faker import Faker


def generate_test_data(seed):
    random = Random(seed)
    faker = build_faker(seed)
    return [
        generate_table(random, faker)
        for i in range(random.randint(1, 10))
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


def resolve_seed(verbose, seed):
    seed = seed if seed is not None else randint(0, 999999)
    if verbose:
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
