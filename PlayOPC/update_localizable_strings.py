#!/usr/bin/env python3

import sys
import re

with open(sys.argv[1], 'r', encoding='utf-8') as f: master = f.readlines()
master = [line.rstrip('\n') for line in master]
#for line in master: print(line)

with open(sys.argv[2], 'r', encoding='utf-8') as f: latest = f.readlines()
latest = [line.rstrip('\n') for line in latest]
#for line in latest: print(line)

pattern = re.compile(r'^".+?" = ".+";$')
messages = {}
for line in latest:
    if pattern.fullmatch(line):
        line = line.lstrip('"').rstrip('";')
        values = line.split('" = "', maxsplit=1)
        messages[values[0]] = values[1]
#for k, v in messages.items(): print(k, v)

for line in master:
    if pattern.fullmatch(line):
        line = line.lstrip('"').rstrip('";')
        values = line.split('" = "', maxsplit=1)
        if values[0] in messages:
            print('"', values[0], '" = "', messages[values[0]], '";', sep='')
        else:
            print('"', line, '";', sep='')
    else:
        print(line)
