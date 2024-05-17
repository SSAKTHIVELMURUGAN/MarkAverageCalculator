import json
import boto3
from uuid import uuid4
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('DB_TABLE_NAME')  # Replace with your table name

def lambda_handler(event, context):
    # Get subject marks from the request body
    subject_marks = json.loads(event['body'])['subjectMarks']

    # Calculate total, average, and percentage
    total = sum(subject_marks)
    average = total / len(subject_marks)
    percentage = (average / 100) * 100

    # Convert float values to Decimal for DynamoDB
    total = Decimal(str(total))
    average = Decimal(str(average))
    percentage = Decimal(str(percentage))
    subject_marks = [Decimal(str(mark)) for mark in subject_marks]

    # Optionally store data in DynamoDB (with error handling)
    try:
        # Use a generated UUID string for the ID (as chosen)
        item_id = str(uuid4())
        table.put_item(Item={
            'ID': item_id,  # Use 'ID' as the key name
            'subjectMarks': subject_marks,
            'total': total,
            'average': average,
            'percentage': percentage
        })
        # Success message (optional)
        print(f"Data stored successfully in DynamoDB with ID: {item_id}")
    except Exception as e:
        # Handle DynamoDB errors
        print(f"Error storing data in DynamoDB: {e}")
        return {
            'statusCode': 500,  # Internal server error
            'body': json.dumps({'error': 'Failed to store data in DynamoDB'})
        }

    # Return the calculated values
    return {
        'statusCode': 200,
        'body': json.dumps({
            'total': float(total),  # Convert Decimal back to float for the response
            'average': float(average),
            'percentage': float(percentage)
        })
    }
