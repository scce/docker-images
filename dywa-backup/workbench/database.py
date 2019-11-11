import psycopg2
from dotenv import dotenv_values


def open_database_connection():
    config = dotenv_values()
    return psycopg2.connect(
        host=config["POSTGRES_HOST"],
        port=config["POSTGRES_PORT"],
        dbname=config["POSTGRES_DB"],
        user=config["POSTGRES_USER"],
        password=config["POSTGRES_PASSWORD"]
    )
