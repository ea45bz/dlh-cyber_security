#!/usr/bin/env python3
import requests
import urllib
from bs4 import BeautifulSoup

#!/usr/bin/env python3
import requests
import urllib
from bs4 import BeautifulSoup

def crawl_website(start_url, max_depth=2):
  result_set=set()
  result_set.add(start_url)
  max_depth-=1
  if max_depth >= 0:
    try:
      page = requests.get(start_url)
      soup = BeautifulSoup(page.content, 'html.parser')
      links = soup.find_all("a")
      for link in links:
        try:
          url=urllib.parse.urljoin(start_url,link['href'])
          #print(url)
          if urllib.parse.urlparse(start_url).netloc == urllib.parse.urlparse(url).netloc:
            res = crawl_website(url, max_depth)
            result_set =result_set.union(res)
        except Exception:
          pass
      return result_set
    except requests.exceptions.RequestException:
      pass

