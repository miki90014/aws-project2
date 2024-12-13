import os
import jwt
import requests
import boto3
from flask import Flask, request, jsonify, Response
import json
from flask_socketio import SocketIO
from flask_cors import CORS
import logging
from db_handler import DatabaseHandler

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

rooms = []
rooms_details = {}

region = os.getenv('AWS_REGION')
app_client_id = os.getenv('COGNITO_CLIENT_ID')
user_pool_id = os.getenv('COGNITO_POOL_ID')

db_handler = DatabaseHandler()



cognito_client = boto3.client('cognito-idp',
                              region_name=region)

def get_jwk(jwks_url):
    jwks = requests.get(jwks_url).json()
    return {key["kid"]: jwt.algorithms.RSAAlgorithm.from_jwk(key) for key in jwks['keys']}


jwks_url = f'https://cognito-idp.{region}.amazonaws.com/{user_pool_id}/.well-known/jwks.json'
jwks = get_jwk(jwks_url)

def validate_token(access_token):
    try:
        headers = jwt.get_unverified_header(access_token)
        key_id = headers['kid']
        public_key = jwks[key_id]
        decoded_token = jwt.decode(access_token, public_key, algorithms=['RS256'])
        return decoded_token
    except jwt.PyJWTError as error:
        logger.error(f"JWT decode error: {error}")
        return None


@app.route('/')
def hello_world():
    return 'Hello, World!'


@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON format"}), 400

    logger.info(data)

    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    logger.info(f"Received signup request for username: {username}")

    try:
        response = cognito_client.sign_up(
            ClientId=app_client_id,
            Username=username,
            Password=password,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                }
            ]
        )
        logger.info(f"Signup successful for username: {username}")
        return jsonify({"message": "Signup successful"}), 200
    except Exception as e:
        logger.error(f"Error occurred during signup for username {username}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON format"}), 400

    username = data.get('username')
    password = data.get('password')

    logger.info(f"Received login request for username: {username}")

    try:
        response = cognito_client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': password
            },
            ClientId=app_client_id
        )
        logger.info(f"Login successful for username: {username}")
        return jsonify(response["AuthenticationResult"])
    except Exception as e:
        logger.error(f"Error occurred during login for username {username}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@app.route('/refresh_token', methods=['POST'])
def refresh_token():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Invalid JSON format"}), 400

    refresh_token = data.get('refreshToken')
    logger.info("Received token refresh request")
    logger.info(refresh_token)
    try:
        response = cognito_client.initiate_auth(
            AuthFlow='REFRESH_TOKEN_AUTH',
            AuthParameters={
                'REFRESH_TOKEN': refresh_token
            },
            ClientId=app_client_id
        )
        logger.info("Token refresh successful")
        return jsonify({"message": "Refreshed successful"}), 200
    except Exception as e:
        logger.error(f"Error occurred during token refresh: {str(e)}")
        return jsonify({"error": str(e)}), 400


@app.route('/logout', methods=['POST'])
def logout():
    logger.info( request.headers)
    access_token = request.headers.get('Authorization')
    access_token = access_token[7:]
    logger.info(access_token)
    try:
        cognito_client.global_sign_out(AccessToken=access_token)
        logger.info("Logout successful")
        return jsonify({"message": "Logged out successfully"})
    except Exception as e:
        logger.error(f"Error occurred during logout: {str(e)}")
        return jsonify({"error": str(e)}), 400



@app.route('/users', methods=['GET'])
def list_cognito_users():
    access_token = request.headers.get('Authorization')
    access_token = access_token[7:]
    if not access_token or validate_token(access_token) is None:
        return jsonify({"error": f"Authentication required: {str(e)}"}), 400
    try:
        users = []
        response = cognito_client.list_users(UserPoolId=user_pool_id)

        print(response)
        users = response['Users']

        user_list = []
        for user in users:
            user_list.append(user['Username'])

        user_info = {
            'UsernameList': user_list
        }

        return jsonify(user_info), 200

    except Exception as e:
        return jsonify({"error": f"Error occured during fetching users: {str(e)}"}), 500

@app.route('/get_sent_messages', methods=['GET'])
def get_sent_messages():
    access_token = request.headers.get('Authorization')
    logger.info(access_token)
    access_token = access_token[7:]
    if not access_token or validate_token(access_token) is None:
        return jsonify({"error": f"Authentication required: {str(e)}"}), 400
    try:
        data = validate_token(access_token)
        username_sender = data.get('username')
        messages = db_handler.fetch_messages_send(username_sender)
        logger.info(str(messages))
        return jsonify({"messages": messages}), 200
    except Exception as e:
        logger.error(str(e))
        return jsonify({"error": f"Error occured during fetching sent messages: {str(e)}"}), 500

@app.route('/get_recieved_messages', methods=['GET'])
def get_recieved_messages():
    access_token = request.headers.get('Authorization')
    logger.info(access_token)
    access_token = access_token[7:]
    if not access_token or validate_token(access_token) is None:
        return jsonify({"error": f"Authentication required: {str(e)}"}), 400
    try:
        data = validate_token(access_token)
        username_reciever = data.get('username')
        messages = db_handler.fetch_messages_recived(username_reciever)
        logger.info(str(messages))
        return jsonify({"messages": messages}), 200
    except Exception as e:
        logger.error(str(e))
        return jsonify({"error": f"Error occured during fetching sent messages: {str(e)}"}), 500
    
@app.route('/send_message', methods=['POST'])
def send_message():
    access_token = request.headers.get('Authorization')
    logger.info(access_token)
    access_token = access_token[7:]
    if not access_token or validate_token(access_token) is None:
        return jsonify({"error": f"Authentication required: {str(e)}"}), 400
    try:
        data = validate_token(access_token)
        username = data.get('username')
        data = request.get_json()
        if not data:
            return jsonify({"error": "Invalid JSON format"}), 400
        message = data.get('messageToSent')
        reciever = data.get('usernameReciever')
        if message is None or reciever is None:
            return jsonify({"error": "Message and reciever cannot be null"}), 400
        logger.info(f"Saving send message {message} send by {username} to {reciever}")
        db_handler.insert_message(username, message, reciever)
        return jsonify({"message": "Message sent successfully"})
    except Exception as e:
        logger.error(str(e))
        return jsonify({"error": f"Error occured during fetching sent messages: {str(e)}"}), 500

if __name__ == '__main__':
    port = int(os.getenv('BACKEND_PORT', 5000))
    socketio.run(app, port=port, host='0.0.0.0', allow_unsafe_werkzeug=True)