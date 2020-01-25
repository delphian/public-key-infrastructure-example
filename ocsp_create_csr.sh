# Execute on OCSP responder host.
DIR="/root/ca/ocsp"
DOMAIN="guardtone"

# Abort script if any error is encountered
set -e
# Create directory structure
if [ ! -d ${DIR} ]; then
	printf "\n>> Generating ${DIR} directory structure...\n"
	mkdir -p "${DIR}/private" "${DIR}/csr" "${DIR}/certs"
fi
# Generate root ocsp responder private key and encrypt
if [ ! -f ${DIR}/private/ocsp.${DOMAIN}.com.key.pem ]; then
	printf "\n>> Generating root Certificate Authority (CA) private OCSP responder key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/ocsp.${DOMAIN}.com.key.pem"
fi
# Generate root ocsp responder Certificate Signing Request (CSR)
if [ ! -f ${DIR}/csr/ocsp.${DOMAIN}.com.csr ]; then
	printf "\n>> Generating root CA OCSP responder Certificate Signing Request (CSR)...\n"
	printf "!! Common Name should be: ocsp.${DOMAIN}.com !!\n\n"
	openssl req -config "./openssl_root.cnf" -new -key "${DIR}/private/ocsp.${DOMAIN}.com.key.pem" -out "${DIR}/csr/ocsp.${DOMAIN}.com.csr" -extensions "server_cert"
fi
# Print summary
if [ -f ${DIR}/private/ocsp.${DOMAIN}.com.key.pem ]; then
	printf "\n\n>> New OCSP private key:\t\t${DIR}/private/ocsp.${DOMAIN}.crt.pem"
	printf "\n>> New OCSP certificate request:\t${DIR}/csr/ocsp.${DOMAIN}.com.csr\n"
fi
