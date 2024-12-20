import json
import time
import requests

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            message_body = record['body']
            token = record['messageAttributes']['Token']['stringValue']
            backend_url = record['messageAttributes']['URL']['stringValue']
        except Exception as ex:
            print(record)
            print(f"Error: {ex}")
            continue
        
        time.sleep(10)
        
        print(f"Otrzymano wiadomość: {message_body}")
        
        if any(char.isdigit() for char in message_body):
                headers = {
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                }
                payload = {
                    "messageToSent": message_body,
                    "usernameReciever": "admin"
                }
                try:
                    requests.post(url=f'{backend_url}:5000/send_message', headers=headers, json=payload)
                except Exception as ex:
                     print(f"Error: {ex}")
    return {
        'statusCode': 200,
        'body': json.dumps('Przetwarzanie zakończone!')
    }
