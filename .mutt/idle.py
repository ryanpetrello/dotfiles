#!/usr/bin/python3
import imaplib
import re
import select
import subprocess

IDLE_FOLDERS = [
    #("Ryan", "ryan@ryanpetrello.com", "INBOX", 'imap.fastmail.com'),
    #("Ryan", "ryan@ryanpetrello.com", "Sent", 'imap.fastmail.com'),
    ("Mailchimp", "ryan_petrello@intuit.com", "INBOX", 'imap.gmail.com'),
]


def get_keychain_pass(account=None, server='imap.gmail.com'):
    command = 'find-internet-password'
    params = {
        'security': '/usr/bin/security',
        'command': command,
        'account': account,
        'server': server,
        'keychain': '/Users/rpetrello/Library/Keychains/login.keychain',
    }
    command = "sudo -u rpetrello %(security)s -v %(command)s -g -a %(account)s -s %(server)s %(keychain)s" % params
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    outtext = [l for l in output.splitlines()
               if l.decode('utf-8').startswith('password: ')][0]

    pw = re.match(r'password: "(.*)"', outtext.decode('utf-8')).group(1)
    return pw


class _sock():

    def __init__(self, name, user, directory, server='imap.gmail.com'):
        password = get_keychain_pass(user, server)
        self.name = name
        self.directory = directory
        print("Connecting to %s %s [%s]" % (name, user, server))
        self.imap = imaplib.IMAP4_SSL(server)
        self.imap.login(user, password)
        self.imap.select(self.directory)
        print( "IDLE for %s" % self.directory)
        self.imap.send(b"%s IDLE\r\n" % self.imap._new_tag())
        assert self.imap.readline() == b'+ idling\r\n'

    def fileno(self):
        return self.imap.socket().fileno()


if __name__ == '__main__':
    sockets = [_sock(*args) for args in IDLE_FOLDERS]
    readable, _, _ = select.select(sockets, [], [], 60 * 5)  # 5 min timeout

    for sock in readable:
        print("-u basic -o")
        break
