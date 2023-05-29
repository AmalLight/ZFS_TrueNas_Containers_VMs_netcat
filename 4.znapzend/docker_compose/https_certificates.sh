#!/bin/bash

# apt install openssl -y

old=$PWD ; cd certificates

touch index.txt  &&  echo 1000 > serial.txt
   
openssl genrsa -out private-ca.key 2048
openssl req    -out public-ca.crt  \
               \
               -sha256 -new -key private-ca.key \
               \
               -x509 -days 365 -config shortCA.conf -extensions v3_ca

for  file_name in `ls shortSV_*.conf`
do
     echo $file_name

     file_name_name="${file_name/.conf/}"

     openssl genrsa -out ${file_name/.conf/}.key    2048
     openssl req    -out ${file_name/.conf/}.csr -sha256 -new \
                    -key ${file_name/.conf/}.key -config $file_name

     yes | \
     openssl ca -out ${file_name/.conf/}.crt  -md sha256 \
                 -in ${file_name/.conf/}.csr -notext -days 365 -config shortCA.conf -extensions server_cert
done

cd $old
echo list_files_in_certificates
ls               ./certificates/

# openssl certificates creator
# this script must be executed from 'Keycloak_scripts/Docker_Compose_FastAPI_NoJSON' folder 
# index.txt and serial.txt from line 7 are temporary files

# from line 9 to line 14 we have some instructions to create our main CA certificate ( the root ).
# from line 16 to line 29 we have some instructions to create the sub certificates for the docker's services ( our sub machines )
# from line 31 to 33 we have some instructions to go back to the 'Keycloak_scripts/Docker_Compose_FastAPI_NoJSON' folder and to watch the contents we have just created

# The logic is that:
# NEW PRIVATE ROOT KEY (PEM)
# NEW PRIVATE ROOT CSR (PEM) from PRIVATE ROOT KEY (PEM)
# NEW PUBLIC  ROOT CRT (PEM) from PRIVATE ROOT PEM (CSR + KEY)
#
# NEW PRIVATE SUBS KEY (PEM)
# NEW PRIVATE SUBS CSR (PEM) from PRIVATE SUBS KEY (PEM)
#
# NEW PUBLIC SUBS CRT (PEM) from PRIVATE ROOT KEY (PEM) +
#                                PUBLIC  ROOT CRT (PEM) +
#                                PRIVATE SUBS CSR (PEM) .
