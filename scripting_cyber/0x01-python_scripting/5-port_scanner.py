#!/usr/bin/env python3
import socket

def check_port(host, port):
  try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(5)
    result = s.connect_ex((host, port))
    s.close()
    if result == 0:
      return True
    return False
  except Exception:
    return False
