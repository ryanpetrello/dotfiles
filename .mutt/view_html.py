#! /usr/bin/env python

# Take an mbox HTML message (e.g. from mutt), splits its parts,
# and rewrite it so it can be viewed in an external browser.
#
# Can be run from within a mailer like mutt, or independently
# on a single message file.

import email
import mimetypes
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import uuid


def view_html_message(tmpdir):
    with open('/Users/ryan/.mail/temporary/cur-message', 'rb') as data:
        msgid = data.read()

    fnames = subprocess.check_output(['notmuch', 'search', '--output=files', '%s' % msgid])
    for line in fnames.splitlines():
        if 'INBOX' in line:
            with open(fnames.splitlines()[0], 'rb') as data:
                msg = email.message_from_string(data.read())
                break

    html_parts = []
    subfiles = []
    for part in msg.walk():
        if part.is_multipart() or part.get_content_type == 'message/rfc822':
            continue

        if part.get_content_subtype() == 'html':
            html_parts.append(part)

        # Save it to a file in the temp dir.
        ext = mimetypes.guess_extension(part.get_content_type()) or '.bin'
        filename = 'part-%03d%s' % (uuid.uuid4(), ext)
        filename = os.path.join(tmpdir, filename)

        for k in part.keys():
            if k.lower() == 'content-id':
                content_id = part[k]
                if content_id.startswith('<') and content_id.endswith('>'):
                    content_id = content_id[1:-1]

                subfiles.append((content_id, filename))
                with open(filename, 'wb') as fp:
                    fp.write(part.get_payload(decode=True))
                break

    htmlfile = os.path.join(tmpdir, "viewhtml.html")
    with open(htmlfile, 'wb') as fp:
        for part in html_parts:
            htmlsrc = part.get_payload(decode=True)

            # Substitute all the filenames for CIDs:
            for content_id, filename in subfiles:
                htmlsrc = re.sub('cid: ?%s' % content_id,
                                 'file://%s' % filename,
                                 htmlsrc, flags=re.IGNORECASE)

            fp.write(htmlsrc)
            fp.close()

    subprocess.check_call(['open', htmlfile])

    # Wait a while to make sure firefox has loads the imgaes, then clean up.
    time.sleep(3)
    shutil.rmtree(tmpdir)


if __name__ == '__main__':
    tmpdir = tempfile.mkdtemp()
    view_html_message(tmpdir)
