from flask import Flask, request, render_template, redirect, url_for
import os
import boto3
import pymysql
import json

app = Flask(__name__)
template_dir = os.path.relpath('./templates')

def execute_query(query: str, params):
    client = boto3.client('secretsmanager', region_name="us-east-1")
    get_secret_value_response = client.get_secret_value(SecretId="SecretsManagerTutorialAdmin-vd0e2uVyx9Va")
    secret = get_secret_value_response['SecretString']
    secret_dict = json.loads(secret)
    db_host = secret_dict['host']
    db_port = secret_dict.get('port', 3306)
    db_user = secret_dict['username']
    db_pass = secret_dict['password']
    db_name = secret_dict['dbname']

    connection = pymysql.connect(
    host=db_host,
    user=db_user,
    password=db_pass,
    port=db_port,
    database = "test_schema"            # DB name??
    )

    cursor = connection.cursor()
    cursor.execute(query, params)
    res = cursor.fetchall()
    print(res)
    cursor.close()
    connection.close()
    return res

@app.route('/')
def index():
    return redirect(url_for("home"))

@app.route('/home')
def home():
    return render_template('home.html')

@app.route('/content')
def content():

    table_name = "test_table"           # table name??
    query = f"SELECT * FROM {table_name}"
    params = ()
    content = execute_query(query, params)

    return render_template('content.html', content=content)

@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'POST':        # example values, TODO when DB will be up
        id = request.form['id']
        name = request.form['name']

        table_name = "test_table"       # table name??
        query = f"INSERT INTO {table_name} (id, name) VALUES (%s, %s)"
        params = (id, name)
        try:
            execute_query(query, params)
            response = "Item added successfully!"
        except Exception as e:
            response = f"Error has occurred: {e}"
        
        return render_template('add.html', response=response)
    
    return render_template('add.html')

def get_port():
    return 8080

def start_app():
    port = get_port()
    app.run(host="0.0.0.0", port=port, debug=True)

if __name__ == "__main__":
    start_app()