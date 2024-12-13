import mysql.connector
from mysql.connector import Error
import threading
import logging
import os

db_host_name = os.getenv('DATABASE_URL')
db_username = os.getenv('DATABASE_USERNAME')
db_password = os.getenv('DATABASE_PASSWORD')


class DatabaseHandler:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls, *args, **kwargs):
        with cls._lock:
            if not cls._instance:
                cls._instance = super(DatabaseHandler, cls).__new__(cls)
                cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        self.host_name = db_host_name.split(":")[0]
        self.user_name = db_username
        self.user_password = db_password
        self.db_name = "messages"
        self.db_port = int(db_host_name.split(":")[1])
        self.connection = None
        self._create_database()
        self._connect_to_database()

    def _create_database(self):
        try:
            connection = mysql.connector.connect(
                host=self.host_name,
                user=self.user_name,
                passwd=self.user_password,
                port=self.db_port
            )
            cursor = connection.cursor()
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {self.db_name}")
            connection.close()
            logging.info(f"Database '{self.db_name}' created or already exists")
        except Error as e:
            logging.error(f"The error '{e}' occurred while creating the database")

    def _connect_to_database(self):
        try:
            self.connection = mysql.connector.connect(
                host=self.host_name,
                user=self.user_name,
                passwd=self.user_password,
                database=self.db_name,
                port=self.db_port
            )
            self.create_table()
            logging.info("Connection to MySQL DB successful")
        except Error as e:
            logging.error(f"The error '{e}' occurred while connecting to the database")

    def create_table(self):
        create_table_query = """
        CREATE TABLE IF NOT EXISTS messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username_sender VARCHAR(255) NOT NULL,
            message VARCHAR(255) NOT NULL,
            username_receiver VARCHAR(255) NOT NULL,
            message_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE = InnoDB
        """
        cursor = self.connection.cursor()
        try:
            cursor.execute(create_table_query)
            self.connection.commit()
            logging.info("Table 'messages' created successfully")
        except Error as e:
            logging.error(f"The error '{e}' occurred while creating the table")

    def insert_message(self, username_sender, message, username_receiver):
        cursor = self.connection.cursor()
        query = """
        INSERT INTO messages (username_sender, message, username_receiver)
        VALUES (%s, %s, %s)
        """
        try:
            cursor.execute(query, (username_sender, message, username_receiver))
            self.connection.commit()
            logging.info("Message inserted successfully")
        except Error as e:
            logging.error(f"The error '{e}' occurred while inserting message")

    def fetch_messages_send(self, username_sender):
        cursor = self.connection.cursor()
        query = f"""
        SELECT 
            message, username_receiver, message_date
        FROM 
            messages
        WHERE 
            username_sender = '{username_sender}';
        """
        try:
            cursor.execute(query)
            result = cursor.fetchall()
            logging.info("Recived sent messages")
            return result
        except Error as e:
            logging.error(f"The error '{e}' occurred while fetching send messages")
            return None

    def fetch_messages_recived(self, username_receiver):
        cursor = self.connection.cursor()
        query = f"""
        SELECT 
            message, username_sender, message_date
        FROM 
            messages
        WHERE 
            username_receiver = '{username_receiver}';
        """
        try:
            cursor.execute(query)
            result = cursor.fetchall()
            logging.info("Recived recived messages")
            return result
        except Error as e:
            logging.error(f"The error '{e}' occurred while fetching recived messages")
            return None

    def close_connection(self):
        if self.connection:
            self.connection.close()
            logging.info("The connection is closed")
