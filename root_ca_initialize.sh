# Execute on offline root CA
DIR="/root/ca"
DOMAIN="guardtone"
DOMAINNAME="GuardTone"

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
if [ ! -f "${DIR}/private/ca.${DOMAIN}.key.pem" ]; then
	printf "\n>> Generating root Certificate Authority (CA) private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/ca.${DOMAIN}.key.pem"
fi
# Generate root certificate
if [ ! -f "${DIR}/certs/ca.${DOMAIN}.crt.pem" ]; then
	printf "\n>> Generating root CA certificate and self signing...\n"
	printf "!! Common Name should be: ${DOMAINNAME} Root Certificate Authority !!\n\n"
	openssl req -config "./openssl_root.cnf" -new -x509 -sha384 -extensions v3_ca -key "${DIR}/private/ca.${DOMAIN}.key.pem" -out "${DIR}/certs/ca.${DOMAIN}.crt.pem"
fi
# Create root Certificate Revocation List
if [ ! -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Generating root CA Certificate Revocation List (CRL)...\n\n"
	openssl ca -config "./openssl_root.cnf" -gencrl -out "${DIR}/crl/revoked.crl"
fi
# Validate root Certificate Revocation List
if [ -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Validating root CA CRL...\n\n"
	openssl crl -in "${DIR}/crl/revoked.crl" -noout -text
fi
# Print summary
if [ -f "${DIR}/certs/ca.${DOMAIN}.crt.pem" ]; then
	printf "\n\n>> New Root CA Certificate:\t\t\t\t${DIR}/certs/ca.${DOMAIN}.crt.pem"
	printf "\n>> New Root CA Certificate Revocation List (CRL):\t${DIR}/crl/revoked.crl\n\n"
fi
