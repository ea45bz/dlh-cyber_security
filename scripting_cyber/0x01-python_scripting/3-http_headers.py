#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup

def get_http_headers(url):
  try:
    page = requests.get(url)
    return { 'status_code': page.status_code , 'headers': page.headers }
  except requests.exceptions.RequestException:
    return None
