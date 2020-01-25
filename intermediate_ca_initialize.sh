DIR="/root/ca/intermediate"

# Abort script if any error is encountered
set -e
# Create directory structure
if [ ! -d "${DIR}" ]; then
	printf "\n>> Generating intermediate Certificate Authority (CA) directory structure...\n"
	mkdir -p "${DIR}/private" "${DIR}/certs" "${DIR}/crl"
	touch "${DIR}/index.txt"
	echo 1000 > "${DIR}/serial"
	echo 1000 > "${DIR}/crlnumber"
fi
# Generate intermediate private key and encrypt
if [ ! -f "${DIR}/private/home.ca.guardtone.key.pem" ]; then
	printf "\n>> Generating intermediate CA private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/home.ca.guardtone.key.pem"
fi
# Generate intermediate Certificate Signing Request (CSR)
if [ ! -f "${DIR}/csr/home.ca.guardtone.csr" ]; then
	printf "\n>> Generating intermediate CA Certificate Signing Request (CSR) for root CA...\n\n"
	openssl req -config "./intermediate_ca_openssl.cnf" -new -key "${DIR}/private/home.ca.guardtone.key.pem" -out "${DIR}/csr/home.ca.guardtone.csr"
fi
# Generate intermediate certificate revocation list
if [ ! -f "${DIR}/crl/revoked.crl" ]; then
	printf "\n>> Generating intermediate CA Certificate Revocation List (CRL)"
	openssl ca -config "./intermediate_ca_openssl.cnf" -gencrl -out "${DIR}/crl/revoked.crl"
fi
# Summary
if [ -f "${DIR}/csr/home.ca.guardtone.csr" ]; then
	printf "\n\n>> Intermediate Certificate Signing Request (CSR): ${DIR}/csr/home.ca.guardtone.csr\n\n"
fi
