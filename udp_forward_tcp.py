#!/usr/bin/env python
import socket

server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_sock.bind(('127.0.0.1', 42401))
server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_sock.listen(1)

udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_sock.bind(("127.0.0.1", 12345))

while True:
    print("Waiting on client.")
    (client, address) = server_sock.accept()
    print(f"Got connection from {address}. Waiting on UDP.")
    (data, address) = udp_sock.recvfrom(2048)
    print(f"Got Data from {address}!")
    client.sendall(data)
    client.close()
    print("Going back")
