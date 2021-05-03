# -*- coding: utf-8 -*-

import os

DEBUG = False

PLUGINS = [
    'slackbot.plugins',
]

ERRORS_TO = None

'''
Setup timeout for slacker API requests (e.g. uploading a file).
'''
TIMEOUT = 100

# API_TOKEN = '###token###'
########################################################################
APP_ID = 'A0212A8MB1P'
CLIENT_ID = '2047533411056.2036348725057'
CLIENT_SECRET = '87aea3f9b80a14ee4f8818a0a3cc8a53'
SIGNING_SECRET = '19faa49a68ceafc6f1f281591d5d5246'

VERIFICATION_TOKEN = 'ITe0TMspUXBsl000GEDf0Joo'

APP_TOKEN = 'xapp-1-A0212A8MB1P-2020659566533-23afe64fb2e615be167237092d8536291e0e9361628e4fbc7275e29f80d79876'

OAUTH_TOKEN = 'xoxp-2047533411056-2020653601557-2016968060118-6d009649dd1bbe721327bcef9e69903b'

BOT_TOKEN = 'xoxb-2047533411056-2023757814562-8KoMdbG2KgQju0DqhBZbpWAu'
API_TOKEN = "xoxb-2047533411056-2023757814562-8KoMdbG2KgQju0DqhBZbpWAu"
########################################################################

'''
Setup a comma delimited list of aliases that the bot will respond to.

Example: if you set ALIASES='!,$' then a bot which would respond to:
'botname hello'
will now also respond to
'$ hello'
'''
ALIASES = ''

'''
If you use Slack Web API to send messages (with
send_webapi(text, as_user=False) or reply_webapi(text, as_user=False)),
you can customize the bot logo by providing Icon or Emoji. If you use Slack
RTM API to send messages (with send() or reply()), or if as_user is True
(default), the used icon comes from bot settings and Icon or Emoji has no
effect.
'''
# BOT_ICON = 'http://lorempixel.com/64/64/abstract/7/'
# BOT_EMOJI = ':godmode:'

'''Specify a different reply when the bot is messaged with no matching cmd'''
DEFAULT_REPLY = None

for key in os.environ:
    if key[:9] == 'SLACKBOT_':
        name = key[9:]
        globals()[name] = os.environ[key]

try:
    from slackbot_settings import *
except ImportError:
    try:
        from local_settings import *
    except ImportError:
        pass

# convert default_reply to DEFAULT_REPLY
try:
    DEFAULT_REPLY = default_reply
except NameError:
    pass
