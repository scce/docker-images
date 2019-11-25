import time

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


def wait_for_database_connection(timeout=10.0):
    """
    inspired by https://gist.github.com/butla/2d9a4c0f35ea47b7452156c96a4e7b12
    """
    start_time = time.perf_counter()
    while True:
        try:
            open_database_connection().close()
            break
        except Exception as ex:
            time.sleep(0.01)
            if time.perf_counter() - start_time >= timeout:
                raise TimeoutError() from ex
