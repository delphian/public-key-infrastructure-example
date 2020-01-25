# Initialize a Certificate Authority
DIR="/root/ca"
DOMAIN="guardtone"
DOMAIN_NAME="GuardTone"
CA="ca"
CA_NAME="Root"
CA_EXT="v3_ca"
CONFIG="./root_ca_openssl.cnf"

# Abort script if any error is encountered
set -e
# Create directory structure
if [ ! -d "${DIR}" ]; then
	printf "\n>> Generating ${DIR} directory structure...\n"
	mkdir -p "${DIR}/private" "${DIR}/csr" "${DIR}/certs" "${DIR}/crl"
	touch "${DIR}/index.txt"
	echo 1000 > "${DIR}/serial"
	echo 1000 > "${DIR}/crlnumber"
fi
# Generate root private key and encrypt
if [ ! -f "${DIR}/private/${CA}.${DOMAIN}.key.pem" ]; then
	printf "\n>> Generating ${CA_NAME} Certificate Authority (CA) private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/${CA}.${DOMAIN}.key.pem"
fi
# Generate root certificate
if [ ! -f "${DIR}/certs/${CA}.${DOMAIN}.crt.pem" ]; then
	printf "\n>> Generating ${CA_NAME} CA certificate and self signing...\n"
	printf "!! Common Name should be: ${DOMAIN_NAME} ${CA_NAME} Certificate Authority !!\n\n"
	openssl req -config "${CONFIG}" -new -x509 -sha384 -extensions ${CA_EXT} -key "${DIR}/private/${CA}.${DOMAIN}.key.pem" -out "${DIR}/certs/ca.${DOMAIN}.crt.pem"
fi
# Create root Certificate Revocation List
if [ ! -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Generating ${CA_NAME} CA Certificate Revocation List (CRL)...\n\n"
	openssl ca -config "${CONFIG}" -gencrl -out "${DIR}/crl/revoked.crl"
fi
# Print summary
if [ -f "${DIR}/certs/${CA}.${DOMAIN}.crt.pem" ]; then
	printf "\n\n>> New ${CA_NAME} CA Certificate:\t\t\t\t${DIR}/certs/${CA}.${DOMAIN}.crt.pem"
	printf "\n>> New ${CA_NAME} CA Certificate Revocation List (CRL):\t${DIR}/crl/revoked.crl\n\n"
fi
