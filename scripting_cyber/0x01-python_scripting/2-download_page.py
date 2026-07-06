#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup

def download_page(url):
  try:
    page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    return soup.prettify()
  except requests.exceptions.RequestException:
    return ""
