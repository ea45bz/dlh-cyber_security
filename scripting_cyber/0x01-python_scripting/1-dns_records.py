#!/usr/bin/env python3
import dns.resolver

def query_dns_records(domain_name):
  record_types = ['A', 'AAAA', 'MX', 'NS', 'TXT', 'SOA']
  result_dict = {}
  for record_type in record_types:
    try: 
      result = dns.resolver.resolve(domain_name,record_type)
      result_dict[record_type]= [r for r in result.rrset]
    except (dns.resolver.NoAnswer, dns.resolver.NXDOMAIN, dns.resolver.NoNameservers):
      pass
  return result_dict
