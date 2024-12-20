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
        
        print(f"Recieved messege: {message_body}")
        
        if any(char.isdigit() for char in message_body):
                message_body = ''.join([i for i in message_body if not i.isdigit()])
                headers = {
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                }
                payload = {
                    "messageToSent": message_body,
                    "usernameReciever": "admin"
                }
                try:
                    response = requests.post(url=f'{backend_url}:5000/send_message', headers=headers, json=payload)
                except Exception as ex:
                     print(f"Error: {ex}")
                print(f"Recieved response: {response}")
    return {
        'statusCode': 200,
        'body': json.dumps('Przetwarzanie zakończone!')
    }
