# Inspired by https://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
# Switch to root before executing
# Place the OCSP responder Certificate Signing Request (CSR) in /root/ca/csr

# Abort script if any error is encountered
set -e

# Enumerate potential Certificate Signing Requests (CSR)
ls /root/ca/csr

# Choose OCSP CSR to sign
printf "\nEnter file name of OCSP Certificate Signing Request (CSR) to sign. Ommit .csr extension: "
read DOMAIN

# Sign OCSP Certificate Signing Request (CSR)
if [ -f "/root/ca/csr/${DOMAIN}.csr" ]; then
	printf "\n>> Signing ${DOMAIN}.csr...\n\n"
	openssl ca -config "/root/ca/openssl_root.cnf" -extensions ocsp -days 3650 -md sha384 -in "/root/ca/csr/${DOMAIN}.csr" -out "/root/ca/certs/${DOMAIN}.crt.pem"
fi

# Validate OCSP responder certificate
if [ -f "/root/ca/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Validating OCSP responder certificate...\n\n"
	openssl x509 -noout -text -in "/root/ca/certs/${DOMAIN}.crt.pem"
fi

# Summary
if [ -f "/root/ca/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Signed OCSP certificate: /root/ca/certs/${DOMAIN}.crt.pem\n\n"
	printf ">> Please copy the above certificate back to the OCSP server\n\n"
fi
