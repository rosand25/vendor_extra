#!/usr/bin/python

import sys
import datetime
import string
import xdaapi
import re

def main(argc, argv):
    i = 1
    user=""
    password=""
    opdata=""
    version=""
    device=""
    postid=""
    title=""
    showdate=""

    while i < argc:
        if argv[i] == "-u":
            i+=1
            user = argv[i]
        elif argv[i] == "-p":
            i+=1
            password = argv[i]
        elif argv[i] == "-v":
            i+=1
            version = argv[i]
        elif argv[i] == "-d":
            i+=1
            device = argv[i]
        elif argv[i] == "-i":
            i+=1
            postid = argv[i]
        elif argv[i] == "-t":
            i+=1
            showdate= argv[i]
        else:
            print "Invalid argument " + argv[i]
            return 1

        i += 1

    if not user or not password:
        print "User name and password are required, use -u and -p arguments!"
        return 1

    if not version:
        print "Version is required, use -v!"
        return 1

    if not showdate:
        showdate = datetime.datetime.now().strftime("%Y-%m-%d").upper()
    title = "[%s] %s [%s]" % (device, version, showdate)
    if not device:
        title = "%s [%s]" % (version, showdate)
    api=xdaapi.XdaApi()
    api.login(user, password)

    with open ("post.txt", "r") as opfile:
        opdata=opfile.read()

    list = open("update_post.txt", "r")
    for line in list:
        forumid, topicid = line.split("=", 1)
        if not device or device == forumid:
            print "Working on " + forumid
            title = "[ROM][7.1.1][OMS] OmniROM %s HOMEMADE [%s]" % (version, showdate)
            api.reply_post(forumid, topicid, title, opdata)

    api.logout_user()
    return 0

if __name__ == "__main__":
   exit(main(len(sys.argv), sys.argv))

