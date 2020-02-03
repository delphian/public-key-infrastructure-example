# Initialize a Certificate Authority
DIR="/root/ca/intermediate/home"
CERT_URL="ca.home.guardtone.com"
CERT_NAME="Home GuardTone Certificate Authority"
CONFIG="./intermediate_ca_home_openssl.cnf"

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
# Generate private key and encrypt
if [ ! -f "${DIR}/private/${CERT_URL}.key.pem" ]; then
	printf "\n>> Generating ${CERT_NAME} private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/${CERT_URL}.key.pem"
fi
# Generate Certificate Signing Request (CSR)
if [ ! -f "${DIR}/certs/${CERT_URL}.crt.pem" ]; then
	printf "\n>> Generating ${CERT_NAME} Certificate Signing Request (CSR)...\n"
	printf "!! Common Name should be: ${CERT_NAME} !!\n\n"
	openssl req -config "${CONFIG}" \
	            -new -sha384 \
		    -key "${DIR}/private/${CERT_URL}.key.pem" \
		    -out "./${CERT_URL}.crs"
fi
# Create Certificate Revocation List
if [ ! -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Generating ${CERT_NAME} Certificate Revocation List (CRL)...\n\n"
	openssl ca -config "${CONFIG}" -gencrl -out "${DIR}/crl/revoked.crl"
fi
# Summary
if [ -f "${DIR}/certs/${CERT_DOMAIN}.crt.pem" ]; then
	printf "\n\n>> New ${CERT_NAME} Certificate Signing Request (CSR):\t./${CERT_URL}.csr"
	printf "\n>> New ${CERT_NAME} Certificate Revocation List (CRL):\t\t${DIR}/crl/revoked.crl\n\n"
fi
