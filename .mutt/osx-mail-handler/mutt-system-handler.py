#!/usr/bin/python

import struct
import subprocess
import urlparse

from objc import signature
from AppKit import *  # noqa
from Foundation import *  # noqa
from PyObjCTools import AppHelper


class AppDelegate(NSObject):

    def applicationWillFinishLaunching_(self, notification):
        man = NSAppleEventManager.sharedAppleEventManager()
        man.setEventHandler_andSelector_forEventClass_andEventID_(
            self,
            "openURL:withReplyEvent:",
            struct.unpack(">i", "GURL")[0],
            struct.unpack(">i", "GURL")[0])
        man.setEventHandler_andSelector_forEventClass_andEventID_(
            self,
            "openURL:withReplyEvent:",
            struct.unpack(">i", "WWW!")[0],
            struct.unpack(">i", "OURL")[0])
        NSLog("Registered URL handler")

    @signature('v@:@@')
    def openURL_withReplyEvent_(self, event, replyEvent):
        keyDirectObject = struct.unpack(">i", "----")[0]
        url = event.paramDescriptorForKeyword_(
            keyDirectObject
        ).stringValue().decode('utf8')

        schema, args = url.split(':')
        NSLog("Received URL: %@", url)

        if schema == 'mailto':
            address = args
            remainder = {}
            if '?' in args:
                address, remainder = args.split('?')
                remainder = dict(map(
                    lambda i: (i[0].lower(), i[1][0]),
                    urlparse.parse_qs(remainder).items()
                ))
            compose(address, **remainder)


def compose(address, subject=None):
    osa = '''
        tell application "Mutt"
            activate
            tell application "System Events"
                keystroke ":exec mail"
                keystroke return
                keystroke "%s"
    ''' % address

    if subject:
        osa += '''
                keystroke return
                keystroke return
                keystroke "%s"
                keystroke return
        ''' % subject

    osa += '''
            end tell
        end tell
    '''

    NSLog(osa)

    p = subprocess.Popen(
        ['osascript', '-'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = p.communicate(osa)
    NSLog('%s %s %s' % (p.returncode, stdout, stderr))


def main():
    app = NSApplication.sharedApplication()

    delegate = AppDelegate.alloc().init()
    app.setDelegate_(delegate)

    AppHelper.runEventLoop()

if __name__ == '__main__':
    main()
