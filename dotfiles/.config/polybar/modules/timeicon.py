#!/bin/python

#  1    󱑋   󱐿
#  2    󱑌   󱑀
#  3    󱑍   󱑁
#  4    󱑎   󱑂
#  5    󱑏   󱑃
#  6    󱑐   󱑄
#  7    󱑑   󱑅
#  8    󱑒   󱑆
#  9    󱑓   󱑇
# 10    󱑔   󱑈
# 11    󱑕   󱑉
# 12    󱑖   󱑊

import datetime

mappedChars = {
    -1: "󰅚",

    0: "󱑖",
    1: "󱑋",
    2: "󱑌",
    3: "󱑍",
    4: "󱑎",
    5: "󱑏",
    6: "󱑐",
    7: "󱑑",
    8: "󱑒",
    9: "󱑓",
    10: "󱑔",
    11: "󱑕",
    12: "󱑖",

    13: "󱑋",
    14: "󱑌",
    15: "󱑍",
    16: "󱑎",
    17: "󱑏",
    18: "󱑐",
    19: "󱑑",
    20: "󱑒",
    21: "󱑓",
    22: "󱑔",
    23: "󱑕",
    24: "󱑖",
}

def getHours():
    return datetime.datetime.now().hour

def getSymbolByValue(value):
    for char in mappedChars:
        if(value < char):
            return mappedChars[value]
    return mappedChars[-1]

print(getSymbolByValue(getHours()))