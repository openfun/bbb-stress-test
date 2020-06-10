#!/usr/bin/env python3
"""
CLI to list running meetings on a BBB server
"""

import argparse
import json
import logging
import os
import sys
from urllib.error import URLError

from bigbluebutton_api_python import BigBlueButton

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))


def get_meetings(bbb, server):
    """Fetch running meeting information from the BBB API"""
    logging.info("Fetching meetings from %s", server)
    try:
        meetings_xml = bbb.get_meetings()
        if meetings_xml.get_field("returncode") == "SUCCESS":
            if meetings_xml.get_field("meetings") == "":
                logging.info("No meetings found on %s", server)
                return []
            raw_meetings = meetings_xml.get_field("meetings")["meeting"]
            logging.info("Meetings found :")
            if isinstance(raw_meetings, list):
                return json.loads(json.dumps(raw_meetings))
            return [json.loads(json.dumps(raw_meetings))]
        logging.error("API request failed")
    except URLError as error:
        logging.error(error)
    return []


def show_meetings(bbb, server):
    """Display meetings currently running on the BBB server"""
    meetings = get_meetings(bbb, server)
    for meeting in meetings:
        logging.info("- %s : %s", meeting["meetingID"], meeting["meetingName"])


def main():
    """Script entrypoint"""
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--url", help="BBB URL", default=os.getenv("BBB_URL"))
    parser.add_argument(
        "-s", "--secret", help="BBB Secret", default=os.getenv("BBB_SECRET")
    )
    args = parser.parse_args()

    if args.url is None or args.secret is None:
        logging.error(
            "Error: Please specify BBB url (-u) and secret (-s) or the path to the config file"
        )
        sys.exit()

    bbb = BigBlueButton(args.url, args.secret)
    show_meetings(bbb, args.url)
