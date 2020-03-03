#!/usr/bin/env python

import requests
import json
import logging
import sys

# for token: https://my.slack.com/customize ->
# window.prompt("your api token is: ", TS.boot_data.api_token)
TOKEN = ''
CHANNEL = '#website-bots'
DATE_BEFORE = '3/1/2020'

LOGGING_FORMAT = '[%(asctime)-15s] %(message)s'
logging.basicConfig(format=LOGGING_FORMAT, stream=sys.stdout, level=logging.INFO)


# docs: https://api.slack.com/methods/search.messages
def get_message_log(page_id=1):
    resp = requests.get(
        url='https://slack.com/api/search.messages',
        params={
            'token': TOKEN,
            'query': 'in:{} before:{} from:crawler'.format(CHANNEL, DATE_BEFORE),
            'sort': 'timestamp',
            # 'count': 10,
            'page': page_id
        })
    resp = json.loads(resp.content)
    logging.debug(resp)
    if not resp['ok']:
        logging.error("failed to search slack messages: {}".format(resp))
        return
    extract = lambda m: (m['channel']['id'], m['ts'], m['text'])
    return map(extract, resp['messages']['matches']), resp['messages']['pagination']['page_count']


# https://api.slack.com/methods/chat.delete/test
def rm_message(channel, ts):
    resp = requests.post(
        url='https://slack.com/api/chat.delete',
        data={
            'token': TOKEN,
            'channel': channel,
            'ts': ts,
        }
    )
    return resp.content


page_i = 1
while True:
    messages, page_count = get_message_log(page_i)
    logging.info('currently on page {}'.format(page_i))
    for message in messages:
        logging.info('deleting message: "{}"'.format(message[2]))
        rm_resp = json.loads(rm_message(message[0], message[1]))
        if not rm_resp['ok']:
            logging.error(rm_resp)
            sys.exit(1)
    if page_i == page_count or not messages:
        logging.info('page count hit or no more messages')
        break
    page_i += 1
