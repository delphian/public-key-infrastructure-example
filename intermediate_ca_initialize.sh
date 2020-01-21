# Inspired by instructions from http://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
#
# Switch to root before executing

DIR="/root/ca/intermediate"
DIR_OUT_CSR="."

#
# Abort script if any error is encountered
set -e

#
# Create directory structure
if [ ! -d "${DIR}" ]; then
	printf "\n>> Generating intermediate Certificate Authority (CA) directory structure...\n"
	mkdir -p "${DIR}/private"
	mkdir -p "${DIR}/certs" "${DIR}/crl"
	mkdir -p "${DIR}/servers"
	mkdir -p "${DIR}/servers/csr" "${DIR}/servers/certs"
	touch "${DIR}/index.txt"
	echo 1000 > "${DIR}/serial"
	echo 1000 > "${DIR}/crlnumber"
	cp openssl_intermediate.cnf "${DIR}/openssl_intermediate.cnf"
fi

#
# Generate intermediate private key and encrypt
if [ ! -f "${DIR}/private/home.ca.guardtone.key.pem" ]; then
	printf "\n>> Generating intermediate CA private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out "${DIR}/private/home.ca.guardtone.key.pem"
fi

#
# Generate intermediate Certificate Signing Request (CSR)
if [ ! -f "${DIR}/csr/home.ca.guardtone.csr" ]; then
	printf "\n>> Generating intermediate CA Certificate Signing Request (CSR) for root CA...\n\n"
	openssl req -config "${DIR}/openssl_intermediate.cnf" -new -key "${DIR}/private/home.ca.guardtone.key.pem" -out "${DIR_OUT_CSR}/home.ca.guardtone.csr"
fi

#
# Summary
if [ -f "${DIR_OUT_CSR}/home.ca.guardtone.csr" ]; then
	printf "\n\n>> Intermediate Certificate Signing Request (CSR): ${DIR_OUT_CSR}/home.ca.guardtone.csr\n\n"
	printf ">> Place the Intermediate CSR into your root CA signing directory (probably /root/ca/csr/) and use the root scripts to sign the request. Once done place the signed certificate (probably /root/ca/certs/home.ca.guardtone.crt.pem) into /home/ca/intermediate/private/certs/\n\n"
fi

#
# Generate intermediate certificate revocation list
#if [ ! -f "${DIR}/crl/revoked.crl" ]; then
#	printf "\n>> Generating intermediate CA Certificate Revocation List (CRL)"
#	openssl ca -config "${DIR}/openssl_intermediate.cnf" -gencrl -out "${DIR}/crl/revoked.crl"
#	openssl crl -in "${DIR}/crl/revoked.crl" -noout -text
#fi
