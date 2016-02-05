#! /usr/bin/env python

# pip install watchdog
# brew install terminal-notifier

import cgi
import email
import email.header
import hashlib
import json
import os
import re
import ssl
import sys
import subprocess
import urllib
import urllib2

from email.utils import parseaddr


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
            s,
            flags=re.I
        )
    s = s.replace('[openstack-dev] ', '')
    return re.sub('\[', '\\\[', s, 1)

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

    avatar = None
    if 'X-GitHub-Sender' in msg:
        resp = urllib.urlopen(
            'https://api.github.com/users/%s' % re.escape(
                msg['X-GitHub-Sender']
            )
        )
        avatar = json.loads(resp.read())['avatar_url']
    else:
        payloads = msg.get_payload() if msg.is_multipart() else [msg.get_payload()]
        for payload in payloads:
            if not isinstance(payload, str):
                continue
            if 'Jenkins has posted comments on this change' in payload:
                avatar = "https://ryanpetrello.com/jenkins.png"

    if avatar is None:
        try:
            sender_domain = address.split('@')[1]
            try:
                import tldextract
                match = tldextract.extract(sender_domain)
                if match:
                    sender_domain = match.registered_domain
            except ImportError:
                pass
            if sender_domain not in ('gmail.com', 'yahoo.com', 'hotmail.com'):
                favicon = 'https://%s' % '/'.join([sender_domain, 'favicon.ico'])
                request = urllib2.Request(favicon)
                request.get_method = lambda: 'HEAD'
                try:
                    ctx = ssl.create_default_context()
                    ctx.check_hostname = False
                    ctx.verify_mode = ssl.CERT_NONE
                    resp = urllib2.urlopen(request, context=ctx, timeout=1)
                    if resp.getcode() == 200:
                        avatar = resp.geturl()
                except (urllib2.URLError, ssl.CertificateError):
                    pass  # ignore errors and invalid certs
        except IndexError:
            pass # invalid From:

    if avatar:
        avatar = 'https://www.gravatar.com/avatar/%s?d=%s' % (
            hashlib.md5(address).hexdigest(),
            avatar
        )
    else:
        avatar = 'https://www.gravatar.com/avatar/%s?d=retro' % (
            hashlib.md5(address).hexdigest()
        )

    if 'X-Gerrit-ChangeURL' in msg:
        event = 'open -a Safari \"%s\"' % cgi.escape(
            re.sub('[<>]', '', msg['X-Gerrit-ChangeURL'])
        )
    elif re.search('<[^@]+@github.com>', uuid):
        pull = re.search('<([^@]+)@github.com>', uuid).group(1)
        pull = ''.join(re.split('(pull/[0-9]+)', pull)[:2])
        event = 'open -a Safari \"%s\"' % cgi.escape('https://github.com/'+pull)
    else:
        uuid = re.sub(r'([^a-zA-Z0-9\s])', r'[\\\\\\\\\1]', uuid)
        event = '/Users/ryan/.mutt/open-message-from-notification \"%s\" \"%s\"' % (folder, uuid)

    args = map(decode, [
        '/usr/local/bin/terminal-notifier', '-message', subject, '-title', title,
        '-subtitle', sender, '-contentImage', avatar,
        '-sender', 'com.apple.Terminal',
        '-appIcon', 'https://ryanpetrello.com/mutt.png'
    ]) + ['-execute', event]

    with open(os.path.expanduser('~/.mutt/error.log'), 'a') as log:
        try:
            subprocess.check_call(args, stdout=log, stderr=log)
        except Exception as e:
            log.write(' '.join(args))
            log.write('\n'+str(e)+'\n')
            log.flush()
