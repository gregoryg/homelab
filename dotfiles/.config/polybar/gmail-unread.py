#!/usr/bin/env python3
## THIS relies on a Google OAuth 2.0 DESKTOP APP credential ref https://developers.google.com/gmail/api/quickstart/python

from __future__ import print_function

import os.path
from datetime import datetime

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Return zippo if we are paused (/tmp/pause-gmail-unread exists)
if os.path.exists('/tmp/pause-gmail-unread'):
    print('')
    exit(0)
# Return zippo if today is a weekend OR it's evening
if datetime.today().weekday() > 4 or datetime.today().hour >17:
    print('')
    exit(0)

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
    # service.users().threads().get(userId='me', id='18346315133d3f93').execute()
    results = service.users().threads().list(userId='me', q="in:inbox is:unread").execute()
    if results['resultSizeEstimate'] > 0:
        print (results['resultSizeEstimate'])
    else:
        print(' ')
except HttpError as error:
    # TODO(developer) - Handle errors from gmail API.
    print(f'An error occurred: {error}')
