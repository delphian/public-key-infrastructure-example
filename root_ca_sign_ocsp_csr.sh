# Sign a OCSP responder Certificate Signing Request (CSR)
# Execute on offline Root Certificate Authority (CA)
DIR="/root/ca"

# Abort script if any error is encountered
set -e
# Enumerate potential Certificate Signing Requests (CSR)
ls "{$DIR}/csr"
# Choose OCSP CSR to sign
printf "\nEnter file name of OCSP Certificate Signing Request (CSR) to sign. Ommit .csr extension: "
read DOMAIN
# Sign OCSP Certificate Signing Request (CSR)
if [ -f "${DIR}/csr/${DOMAIN}.csr" ]; then
	printf "\n>> Signing ${DOMAIN}.csr...\n\n"
	openssl ca -config "./openssl_root.cnf" -extensions ocsp -days 3650 -md sha384 -in "${DIR}/csr/${DOMAIN}.csr" -out "${DIR}/certs/${DOMAIN}.crt.pem"
fi
# Validate OCSP responder certificate
if [ -f "${DIR}/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Validating OCSP responder certificate...\n\n"
	openssl x509 -noout -text -in "${DIR}/certs/${DOMAIN}.crt.pem"
fi
# Summary
if [ -f "${DIR}/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Signed OCSP certificate: ${DIR}/certs/${DOMAIN}.crt.pem\n\n"
	printf ">> Please copy the above certificate back to the OCSP server\n\n"
fi
