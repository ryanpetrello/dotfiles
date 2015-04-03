#! /usr/bin/env python

# Take an mbox HTML message (e.g. from mutt), splits its parts,
# and rewrite it so it can be viewed in an external browser.
#
# Can be run from within a mailer like mutt, or independently
# on a single message file.

import base64
import email
import subprocess
from cStringIO import StringIO


def view_html_message():
    with open('/Users/ryan/.mail/temporary/cur-message', 'rb') as data:
        msgid = data.read()

    fnames = subprocess.check_output(
        ['notmuch', 'search', '--output=files', '%s' % msgid]
    )
    for line in fnames.splitlines():
        if '/archive/' not in line:
            with open(fnames.splitlines()[0], 'rb') as data:
                msg = email.message_from_string(data.read())
                break

    html_parts = []
    subfiles = []
    for part in msg.walk():
        if part.is_multipart() or part.get_content_type() == 'message/rfc822':
            continue

        if part.get_content_subtype() == 'html':
            html_parts.append(part)

        # Save it to a file in the temp dir.
        mime = part.get_content_type()

        for k in part.keys():
            if k.lower() == 'content-id':
                content_id = part[k]
                if content_id.startswith('<') and content_id.endswith('>'):
                    content_id = content_id[1:-1]

                subfiles.append(
                    (content_id, mime, part.get_payload(decode=True))
                )
                break

    buff = StringIO()
    for part in html_parts:
        payload = part.get_payload(decode=True)

        # Substitute all the filenames for CIDs:
        for content_id, mime, attachment in subfiles:
            payload = payload.replace(
                'cid:%s' % content_id,
                'data:%s;base64,%s' % (mime, base64.b64encode(attachment))
            )
        buff.write(payload)

    data = 'data:text/html;base64,' + base64.b64encode(buff.getvalue())
    subprocess.check_call(
        ['open', '-a', '/Applications/Google Chrome.app/', '--args', data]
    )


if __name__ == '__main__':
    view_html_message()