from flask import Flask, request, render_template, redirect, url_for
import os
import boto3
import pymysql
import json

app = Flask(__name__)
template_dir = os.path.relpath('./templates')

SECRET_ID = os.environ.get('SECRET_ID')
REGION = os.environ.get('REGION')
DB_NAME = os.environ.get('DB_NAME')

DB_PORT = 3306
TABLE_NAME = "USERS"

client = boto3.client('secretsmanager', region_name=REGION)
get_secret_value_response = client.get_secret_value(SecretId=SECRET_ID)
secret = get_secret_value_response['SecretString']
secret_dict = json.loads(secret)
db_host = secret_dict['host']
db_user = secret_dict['username']
db_pass = secret_dict['password']

connection = pymysql.connect(
    host=db_host,
    user=db_user,
    password=db_pass,
    port= DB_PORT,
    database = DB_NAME 
)
# Create table if not exists
cursor = connection.cursor()
cursor.execute(f"CREATE TABLE IF NOT EXISTS {TABLE_NAME} (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))")

def add_user(name: str):
    try:
        connection.ping(reconnect=True)  
        cursor = connection.cursor()
        query = f"INSERT INTO {TABLE_NAME} (name) VALUES (%s)"
        cursor.execute(query, (name,))
        connection.commit()  
        cursor.close()
        return "User added successfully!"
    except Exception as e:
        print(f"Error during insertion: {e}")  # Log for debugging
        return f"Error occurred: {e}"


def get_users():
    try:
        connection.ping(reconnect=True)  
        cursor = connection.cursor()
        query = f"SELECT id, name FROM {TABLE_NAME}"
        cursor.execute(query)
        users = cursor.fetchall()
        cursor.close()
        return users
    except Exception as e:
        print(f"Error during retrieval: {e}")  
        return []

@app.route('/')
def index():
    return redirect(url_for("home"))

@app.route('/home')
def home():
    return render_template('home.html')

@app.route('/content')
def content():
    content = get_users()  
    return render_template('content.html', content=content)


@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':      
        name = request.form['name']
        response = add_user(name)  # Use the new add_user function
        return render_template('add.html', response=response)
    return render_template('add.html')


def get_port():
    return 8080

def start_app():
    port = get_port()
    app.run(host="0.0.0.0", port=port, debug=True)

if __name__ == "__main__":
    start_app()