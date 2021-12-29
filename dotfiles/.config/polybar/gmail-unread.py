#!/usr/bin/env python3

from __future__ import print_function

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file gmailapi-token.json.
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

creds = None
# The file gmailapi-token.json stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
if os.path.exists('/home/gregj/.local/gmailapi-token.json'):
    creds = Credentials.from_authorized_user_file('/home/gregj/.local/gmailapi-token.json', SCOPES)
# If there are no (valid) credentials available, let the user log in.
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            '/home/gregj/.local/gmailapi-credentials.json', SCOPES)
        creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open('/home/gregj/.local/gmailapi-token.json', 'w') as token:
        token.write(creds.to_json())

try:
    service = build('gmail', 'v1', credentials=creds)
    results = service.users().messages().list(userId='me', q="in:inbox is:unread").execute()
    messages = []
    if 'messages' in results:
        messages.extend(results['messages'])
    while 'nextPageToken' in results:
        page_token = results['nextpagetoken']
        results = service.users().messages().list(userId='me', q="in:inbox is:unread", pageToken=page_token).execut()
        if 'messages' in results:
            messages.extend(results['messages'])
    # if len(messages):
    print(len(messages))
except HttpError as error:
    # TODO(developer) - Handle errors from gmail API.
    print(f'An error occurred: {error}')
