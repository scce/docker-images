import os
from os.path import join

from workbench.database import open_database_connection


def create_database_dump():
    connection = open_database_connection()
    cursor = connection.cursor()
    dump = list(
        map(
            lambda table: select_all_rows(cursor, table),
            select_all_user_tables(cursor)
        )
    )
    connection.commit()
    connection.close()
    return dump


def select_all_rows(cursor, table_name):
    cursor.execute("SELECT * FROM " + table_name + " ORDER BY id;")
    return cursor.fetchall()


def select_all_user_tables(cursor):
    cursor.execute("SELECT * FROM pg_catalog.pg_tables WHERE tableowner = 'user' ORDER BY tablename;")
    return list(
        map(
            get_table_name,
            cursor.fetchall()
        )
    )


def get_table_name(row):
    return row[1]


def compare_database_dumps(before, after):
    no_tables = []
    no_tables_message = "No tables exist in %s "

    if before == no_tables:
        raise Exception(no_tables_message % "before")

    if after == no_tables:
        raise Exception(no_tables_message % "after")

    return before == after


def create_filesystem_dump(path):
    dump = []
    for directory_path, dirs, filename_list in os.walk(path):
        dump.append(
            read_folder(directory_path, filename_list)
        )
    return dump


def read_folder(directory_path, filename_list):
    return {
        'directory_path': directory_path,
        'file_list': read_files(directory_path, filename_list)
    }


def read_files(directory_path, filename_list):
    file_list = []
    for filename in filename_list:
        file_path = join(directory_path, filename)
        with open(file_path, 'r') as file_path:
            file_list.append({
                'filename': filename,
                'content': file_path.read()
            })
    return file_list


def compare_filesystem_dumps(before, after):
    return before == after
