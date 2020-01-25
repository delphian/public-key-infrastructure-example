# Create a new private key and certificate signing request
DIR="/root/ca"
CERT_URL="ocsp.guardtone.com"
CERT_NAME="Root CA OCSP Responder"
CONFIG="./root_ca_openssl.cnf"

# Abort script if any error is encountered
set -e
# Create directory structure
if [ ! -d ${DIR} ]; then
	printf "\n>> Generating ${DIR} directory structure...\n"
	mkdir -p "${DIR}/private" "${DIR}/csr" "${DIR}/certs"
fi
# Generate root ocsp responder private key and encrypt
if [ ! -f ${DIR}/private/${CERT_URL}.key.pem ]; then
	printf "\n>> Generating ${CERT_NAME} key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/${CERT_URL}.key.pem"
fi
# Generate Certificate Signing Request (CSR)
if [ ! -f ${DIR}/csr/${CERT_URL}.csr ]; then
	printf "\n>> Generating ${CERT_NAME} Certificate Signing Request (CSR)...\n"
	printf "!! Common Name should be: ${CERT_URL} !!\n\n"
	openssl req -config "${CONFIG}" \
	            -new \
		    -key "${DIR}/private/${CERT_URL}.key.pem" \
		    -out "${DIR}/csr/${CERT_URL}.csr"
fi
# Print summary
if [ -f ${DIR}/private/${CERT_URL}.key.pem ]; then
	printf "\n\n>> New ${CERT_NAME} private key:\t\t\t${DIR}/private/${CERT_URL}.crt.pem"
	printf "\n>> New ${CERT_NAME} certificate signing request:\t${DIR}/csr/${CERT_URL}.csr\n"
fi
