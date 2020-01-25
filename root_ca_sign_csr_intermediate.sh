# Sign a Certificate Signing Request (CSR)
DIR="/root/ca"
# ocsp | v3_intermediate_ca | server_cert
EXTENSIONS="v3_intermediate_ca"
DAYS="3650"
CONFIG="./root_ca_openssl.cnf"

# Abort script if any error is encountered
set -e
# Enumerate Certificate Signing Requests (CSR)
ls "${DIR}/csr"
# Choose CSR to sign
printf "\nEnter file name (url) of Certificate Signing Request (CSR) to sign. Omit .csr extension: "
read CERT_URL
# Sign Certificate Signing Request (CSR)
if [ -f "${DIR}/csr/${CERT_URL}.csr" ]; then
	printf "\n>> Signing ${CERT_URL}.csr...\n\n"
	openssl ca -config "${CONFIG}" \
	           -extensions ${EXTENSIONS} \
		   -days ${DAYS} \
		   -md sha384 \
		   -in "${DIR}/csr/${CERT_URL}.csr" \
		   -out "${DIR}/certs/${CERT_URL}.crt.pem"
fi
# Validate signed certificate
if [ -f "${DIR}/certs/${CERT_URL}.crt.pem" ]; then
	printf "\n\n>> Validating signed certificate...\n\n"
	openssl x509 -noout -text -in "${DIR}/certs/${CERT_URL}.crt.pem"
fi
# Summary
if [ -f "${DIR}/certs/${CERT_URL}.crt.pem" ]; then
	printf "\n\n>> Signed certificate: ${DIR}/certs/${CERT_URL}.crt.pem\n\n"
fi
