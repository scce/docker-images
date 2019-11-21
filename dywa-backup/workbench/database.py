import time
import psycopg2
import json
import socket


def open_database_connection():
    config = read_database_config()
    return psycopg2.connect(
        host=config["host"],
        port=config["port"],
        dbname=config["database"],
        user=config["user"],
        password=config["password"]
    )


def read_database_config():
    with open("postgresql-connection.json") as configFile:
        return json.load(configFile)


def wait_for_database_connection(timeout=10.0):
    """
    inspired by https://gist.github.com/butla/2d9a4c0f35ea47b7452156c96a4e7b12
    """
    config = read_database_config()
    start_time = time.perf_counter()
    while True:
        try:
            with socket.create_connection(
                (config["host"], config["port"]),
                timeout=timeout
            ):
                break
        except OSError as ex:
            time.sleep(0.01)
            if time.perf_counter() - start_time >= timeout:
                raise TimeoutError() from ex
