#!/usr/bin/python3

import random
import sys

topic = sys.argv[1]
count = int(sys.argv[2])

start_ts = 1648432611249000000
location = ["SanFrancisco", "LosAngeles", "SanDiego"]
for i in range(count):
    ts = start_ts + i
    row = f"{topic},location={location[i % 3]},groupid=2 current={random.random() * 10},voltage={random.randint(100, 300)},phase={random.random()} {ts}"
    print(row)
 
