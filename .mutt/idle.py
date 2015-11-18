#!/usr/bin/python
import imaplib
import re
import select
import subprocess

IDLE_FOLDERS = [
    ("Ryan", "ryan@ryanpetrello.com", "INBOX"),
    ("Ryan", "ryan@ryanpetrello.com", "[Gmail]/Sent Mail"),
    ("Ryan", "ryan@ryanpetrello.com", "openstack-reviews"),

    ("Lists", "lists@ryanpetrello.com", "INBOX"),
    ("Lists", "lists@ryanpetrello.com", "[Gmail]/Sent Mail"),

    ("DH", "ryan.petrello@dreamhost.com", "INBOX"),
    ("DH", "ryan.petrello@dreamhost.com", "ndn-commit"),
    ("DH", "ryan.petrello@dreamhost.com", "akanda"),
    ("DH", "ryan.petrello@dreamhost.com", "pecan"),
    ("DH", "ryan.petrello@dreamhost.com", "[Gmail]/Sent"),
]


def get_keychain_pass(account=None, server='imap.gmail.com'):
    params = {
        'security': '/usr/bin/security',
        'command': 'find-internet-password',
        'account': account,
        'server': server,
        'keychain': '/Users/ryan/Library/Keychains/login.keychain',
    }
    command = "sudo -u ryan %(security)s -v %(command)s -g -a %(account)s -s %(server)s %(keychain)s" % params
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    outtext = [l for l in output.splitlines()
               if l.startswith('password: ')][0]

    pw = re.match(r'password: "(.*)"', outtext).group(1)
    return pw


class _sock():

    def __init__(self, name, user, directory, server='imap.gmail.com'):
        password = get_keychain_pass(user)
        self.name = name
        self.directory = directory
        print "Connecting to %s [%s]" % (user, server)
        self.imap = imaplib.IMAP4_SSL(server)
        self.imap.login(user, password)
        self.imap.select(self.directory)
        print "IDLE for %s" % self.directory
        self.imap.send("%s IDLE\r\n" % self.imap._new_tag())
        assert self.imap.readline() == '+ idling\r\n'

    def fileno(self):
        return self.imap.socket().fileno()


if __name__ == '__main__':
    sockets = [_sock(*args) for args in IDLE_FOLDERS]
    readable, _, _ = select.select(sockets, [], [], 60 * 5)  # 5 min timeout

    found = False
    for sock in readable:
        print "Received mail on %s" % sock.name
        if sock.imap.readline().startswith('* BYE '):
            continue
        print "-u basic -o -q -f %s -a %s"%(sock.directory, sock.name)
        found = True
        break

    if not found:
        print "-u basic -o"
