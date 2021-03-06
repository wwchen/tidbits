from box import Box
import logging
import sys
import requests
import json


CONFIG = Box.from_yaml(filename='config.yaml')

logging.basicConfig(format=CONFIG.logging.format, stream=sys.stdout, level=CONFIG.logging.level)


def strip_non_ascii(string):
    ''' Returns the string without non ASCII characters'''
    stripped = (c for c in string.strip() if 0 < ord(c) < 127)
    return ''.join(stripped)


def post_to_slack(message, slack_cfg=None):
    slack_webhook_url = CONFIG.slack.webhook_url
    payload = {
        'text': message,
        'username': 'crawler',
        'icon_emoji': ':shirt:',
    }
    if slack_cfg:
        payload.update(slack_cfg)
    if CONFIG.slack.enabled:
        return requests.post(url=slack_webhook_url, json=payload)
    else:
        logging.info('[DRYRUN] Slack post: {}'.format(json.dumps(payload)))


def find_new_additions(curr_results, prev_results):
    prev_titles = map(lambda r: r["title"], prev_results)
    additions = []
    for curr_row in curr_results:
        curr_title = curr_row["title"]
        if curr_title not in prev_titles:
            additions.append(curr_row)
    return additions


def read_cache_file(cache_filename):
    try:
        return json.loads(open(cache_filename).read())
    except ValueError as e:
        # json parsing error
        logging.error(e)
    except IOError as e:
        # file IO error
        logging.error(e)
    return {}


def overwrite_to_cache_file(cache_filename, results):
    with(open(cache_filename, 'w')) as f:
        f.write(json.dumps(results))

def write_html(filename, requests_response):
    with open(filename, 'wb') as f:
        f.write(page.content)
        logging.info(f'saved page as {filename}')

def run(crawler_name, scraper_func):
    crawler_config = CONFIG.crawler[crawler_name]
    cache_filename = '.{}.json'.format(crawler_name)

    prev_results = read_cache_file(cache_filename)
    curr_results = scraper_func(crawler_config)
    if not curr_results:
        message = "didn't scape for anything, page request error?"
        logging.error(message)
        post_to_slack(message, crawler_config.slack)
    additions = find_new_additions(curr_results, prev_results)
    overwrite_to_cache_file(cache_filename, curr_results)
    if additions:
        logging.info("additions compared to last run:")
        message_lines = []
        for row in additions:
            if 'whitelist' in crawler_config and not any([b.lower() in title.lower() for b in crawler_config.whitelist]):
                continue
            if 'blacklist' in crawler_config and any([b.lower() in title.lower() for b in crawler_config.blacklist]):
                continue
            message = ''
            if 'link' in row:
                message = "<{}|{}> - {}".format(row["link"], row["title"], row["price"])
            elif 'links' in row:
                links = ", ".join(["<{}|{}>".format(l['href'], l['text']) for l in row['links']])
                message = "{} ({}) - {}".format(row['title'], links, row['price'])
            else:
                logging.error('cannot read results')
            logging.info(message)
            message_lines.append(message)
        message = ''
        char_count = 0
        for lines in message_lines:
            lines += '\n'
            if char_count + len(lines) > 40000:
                # flush
                post_to_slack(message, crawler_config.slack)
                message = ''
                char_count = 0
            message += lines
            char_count += len(lines)
        post_to_slack(message, crawler_config.slack)
    else:
        logging.info("no new additions")
