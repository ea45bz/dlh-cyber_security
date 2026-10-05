#!/bin/bash

#openssl dgst -sha256 -sign rsa_private.pem -out prescription.txt.sig prescription.txt

#openssl dgst -sha256 -verify rsa_public.pem -signature prescription.txt.sig prescription.txt

#vi prescription.txt

#openssl dgst -sha256 -verify rsa_public.pem -signature prescription.txt.sig prescription.txt
#Verification OK

#openssl dgst -sha256 -verify rsa_public.pem -signature prescription.txt.sig prescription.txt
#Verification Failure


if [ "$1" = "sign" ]; then
  openssl dgst -sha256 -sign $3 -out $2.sig $2
elif [ "$1" = "verify" ]; then
  openssl dgst -sha256 -verify $3 -signature $2.sig $2
fi
