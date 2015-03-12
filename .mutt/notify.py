#! /usr/bin/env python

# pip install watchdog
# brew install terminal-notifier

import base64
import cgi
import email
import email.header
import hashlib
import json
import os
import pipes
import re
import sys
import subprocess
import urllib

def decode(s):

    s = s.replace('\n ', '')
    for prefix, suffix in (
        ('=?utf-8?b?', '?='),
        ('=?utf-8?q?', '?='),
    ):
        s = re.sub(
            r'(%s[^?]+%s)' % (
                prefix.replace('?', '\?'), suffix.replace('?', '\?')
            ),
            lambda m: ''.join([
                unicode(t[0], t[1] or 'ASCII')
                for t in email.header.decode_header(m.group(1))
            ]),
            s
        )
    s = s.replace('[openstack-dev] ', '').replace(']', '').replace('[', '')
    return s

filename = sys.argv[1]
if not os.path.isfile(filename):
    sys.exit(1)
with open(filename) as mail_file:
    msg = email.message_from_file(mail_file)
    folder = '=' + os.path.sep.join(
        os.path.abspath(filename).split('.mail/')[1].split(os.path.sep)[:2]
    )
    title = 'Mutt'
    if msg.get('Delivered-To'):
        title += ' - %s' % msg['Delivered-To']
    uuid = msg['Message-id']
    name, address = email.utils.parseaddr(msg['From'])
    name = urllib.unquote(name)
    subject = msg['Subject']
    if name:
        sender = '%s - %s' % (name, address)
    else:
        sender = address

    if 'X-GitHub-Sender' in msg:
        resp = urllib.urlopen('https://api.github.com/users/%s' % re.escape(msg['X-GitHub-Sender']))
        avatar = json.loads(resp.read())['avatar_url']
    else:
        avatar = 'http://www.gravatar.com/avatar/%s?d=mm' % hashlib.md5(address).hexdigest()

    if 'X-Gerrit-ChangeURL' in msg:
        uuid = 'URLOPEN:'+re.sub('[<>]', '', msg['X-Gerrit-ChangeURL'])
        event = 'open -a Safari \"%s\"' % cgi.escape(
            re.sub('[<>]', '', msg['X-Gerrit-ChangeURL'])
        )
    elif re.search('<[^@]+@github.com>', uuid):
        pull = re.search('<([^@]+)@github.com>', uuid).group(1)
        pull = ''.join(re.split('(pull/[0-9]+)', pull)[:2])
        event = 'open -a Safari \"%s\"' % cgi.escape('http://github.com/'+pull)
    else:
        uuid = re.sub(r'([^a-zA-Z0-9\s])', r'[\\\\\\\\\1]', uuid)
        event = '/Users/ryan/.mutt/open \"%s\" \"%s\"' % (folder, uuid)

    args = map(decode, [
        'terminal-notifier', '-message', subject, '-title', title,
        '-subtitle', sender, '-appIcon', avatar,
        '-sender', 'com.apple.Terminal'
    ]) + ['-execute', event]
    subprocess.check_call(args)
