# Initialize a Certificate Authority
DIR="/root/ca"
CERT_URL="ca-offline.guardtone.com"
CERT_NAME="Root GuardTone Certificate Authority"
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
# Generate private key and encrypt
if [ ! -f "${DIR}/private/${CERT_URL}.key.pem" ]; then
	printf "\n>> Generating ${CERT_NAME} private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/${CERT_URL}.key.pem"
fi
# Generate certificate
if [ ! -f "${DIR}/certs/${CERT_URL}.crt.pem" ]; then
	printf "\n>> Generating ${CERT_NAME} certificate and self signing...\n"
	echo -e "\e[92m!! Common Name should be: ${CERT_NAME} Certificate Authority !!\e[0m"
	printf "\n\n"
	openssl req -config "${CONFIG}" \
	            -new -x509 -sha384 \
		    -extensions v3_ca \
		    -key "${DIR}/private/${CERT_URL}.key.pem" \
		    -out "${DIR}/certs/${CERT_URL}.crt.pem"
fi
# Create Certificate Revocation List
if [ ! -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Generating ${CERT_NAME} Certificate Revocation List (CRL)...\n\n"
	openssl ca -config "${CONFIG}" -gencrl -out "${DIR}/crl/revoked.crl"
fi
# Summary
if [ -f "${DIR}/certs/${CERT_URL}.crt.pem" ]; then
	printf "\n\n"
	echo -e "\e[92m>> ${CERT_NAME} certificate:\t\t\t\t${DIR}/certs/${CERT_URL}.crt.pem"
	echo -e ">> ${CERT_NAME} Certificate Revocation List (CRL):\t${DIR}/crl/revoked.crl\e[0m"
	printf "\n\n"
fi
