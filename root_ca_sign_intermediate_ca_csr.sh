# Place the Certificate Signing Request in /root/ca/csr/
DIR="/root/ca"

# Abort script if any error is encountered
set -e
# Enumerate potential Certificate Signing Requests (CSR)
ls "${DIR}/csr"
# Choose CSR to sign
printf "\nEnter file name of Certificate Signing Request (CSR) to sign. Omit .csr extension: "
read DOMAIN
# Sign intermediate Certificate Signing Request
if [ -f "${DIR}/csr/${DOMAIN}.csr" ]; then
	printf "\n>> Signing ${DOMAIN}.csr...\n\n"
	openssl ca -config "./root_ca_openssl.cnf" -extensions v3_intermediate_ca -days 3650 -md sha384 -in "${DIR}/csr/${DOMAIN}.csr" -out "${DIR}/certs/${DOMAIN}.crt.pem"
fi
# Validate intermediate certificate contents
if [ -f "${DIR}/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Validating intermediate CA Certificate...\n\n"
	openssl x509 -noout -text -in "${DIR}/certs/${DOMAIN}.crt.pem"
fi
# Summary
if [ -f "${DIR}/certs/${DOMAIN}.crt.pem" ]; then
	printf "\n>> Signed intermediate CA Certificate: ${DIR}/certs/${DOMAIN}.crt.pem\n\n"
	printf ">> Copy signed certificate back to intermediate Certificate Authority\n\n"
fi
