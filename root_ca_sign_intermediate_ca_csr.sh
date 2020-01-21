# Inspired by instructions from http://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
#
# Switch to root before executing
#
# Place the Certificate Signing Request in /root/ca/intermediate/csr/

#
# Abort script if any error is encountered
set -e

#
# Enumerate potential Certificate Signing Requests (CSR)
ls /root/ca/csr

#
# Choose CSR to sign
printf "\nEnter file name of Certificate Signing Request (CSR) to sign. Ommit .csr extension: "
read DOMAIN

#
# Sign intermediate Certificate Signing Request
if [ -f "/root/ca/csr/${DOMAIN}.csr" ]; then
	printf "\n>> Signing ${DOMAIN}.csr...\n\n"
	openssl ca -config "/root/ca/openssl_root.cnf" -extensions v3_intermediate_ca -days 3650 -md sha384 -in "/root/ca/csr/${DOMAIN}.csr" -out "/root/ca/certs/${DOMAIN}.crt.pem"
fi

#
# Validate intermediate certificate contents
if [ -f "/root/ca/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Validating intermediate CA Certificate...\n\n"
	openssl x509 -noout -text -in "/root/ca/certs/${DOMAIN}.crt.pem"
fi

#
# Summary
if [ -f "/root/ca/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Signed intermediate CA Certificate: /root/ca/certs/${DOMAIN}.crt.pem\n\n"
	printf ">> Copy signed certificate back to intermediate Certificate Authority (probably /root/ca/intermediate/certs/\n\n"
fi

