#! /usr/bin/env python
# -*- coding: utf-8 -*-

import re
import sys
import urllib2

from collections import defaultdict

def _fetch(path, keys=[]):
    uri = 'http://api.wunderground.com%s' % path
    resp = urllib2.urlopen(uri)
    data = resp.read()

    pattern = r'"%s":"([^"]+)'
    if 'XML' in resp.headers['Content-Type'].upper():
        pattern = r'<%s>([^<]+)'

    matches = defaultdict(list)

    if keys:
        for key in keys:
            for match in re.finditer(pattern % key, data):
                matches[key] += (match.group(1),)
        return matches

    else:
        return data

def _emojify(txt):
    for pattern, sub in (
        (r'\. Highs?', ' ⬆'),
        (r'\. Lows?', ' ⬇'),
        (r' percent', '%'),
        (r'sun(\s|\.)', '🌕 '),
        (r'sunny|sunshine', '🌕 '),
        (r'cloud(y|s|iness)\.?', '☁ '),
        (r'rain(fall)?', '💧 '),
        (r'a shower', '💧 '),
        (r'snow', '❄'),
        (r'a quarter of an', '1/4'),
        (r'(the|this) morning', r'\1 AM'),
        (r'(the|this) (afternoon|evening)', r'\1 PM'),
        (r'(A )?clear( sky)?\.?', '🌘 ')
    ):
        txt = re.sub(pattern, sub, txt, flags=re.I)
    return txt

def _justify(weekday):
    if weekday.endswith('Night:'):
        return "%-3s" % ''
    return '%-3s' % {
        'Thursday:': 'Th:',
        'Sunday:': 'Su:'
    }.get(weekday, '%s:' % weekday[0])

def wunderground(api_key, location):
    print
    matches = _fetch(
        '/auto/wui/geo/WXCurrentObXML/index.xml?query=%s' % location,
        ['city', 'temp_f', 'weather']
    )
    print "%s, %s°F (%s, %s)" % (
        matches['weather'].pop().capitalize(),
        matches['temp_f'].pop(),
        matches['city'].pop(),
        location
    )
    print '---',
    matches = _fetch(
        '/api/%s/forecast10day/q/%s.json' % (
            api_key,
            location
        ),
        ['title', 'fcttext']
    )
    forecasts = zip(matches['title'], matches['fcttext'])
    for i, (weekday, txt) in enumerate(forecasts[:14]):
        if i % 4 == 0:
            color = "\033[1;37;40m"
            print color
        elif i % 2 == 0:
            color = "\033[1;37;100m"
            print
        print "%s%s %s" % (
            color,
            _justify(weekday+':'),
            _emojify(txt)
        )
    print


if __name__ == '__main__':
    wunderground(*sys.argv[1:])
