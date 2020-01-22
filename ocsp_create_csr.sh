# Inspired by instructions from http://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
# Switch to root before executing. To reset and start over first issue 'rm -Rf /root/ca/ocsp'.
# Execute on OCSP responder host.

# Abort script if any error is encountered
set -e

# Create directory structure
if [ ! -d /root/ca/ocsp ]; then
	printf "\n>> Generating /root/ca directory structure...\n"
	mkdir -p /root/ca/ocsp/private /root/ca/ocsp/csr /root/ca/ocsp/certs
fi

# Copy OpenSSL config file
if [ ! -f /root/ca/openssl_root.cnf ]; then
	cp openssl_root.cnf /root/ca/openssl_root.cnf
fi

# Generate root ocsp responder private key and encrypt
if [ ! -f /root/ca/ocsp/private/ocsp.guardtone.com.key.pem ]; then
	printf "\n>> Generating root Certificate Authority (CA) private OCSP responder key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out /root/ca/ocsp/private/ocsp.guardtone.com.key.pem
fi

# Generate root ocsp responder Certificate Signing Request (CSR)
if [ ! -f /root/ca/ocsp/csr/ocsp.guardtone.com.csr ]; then
	printf "\n>> Generating root CA OCSP responder Certificate Signing Request (CSR)...\n\n"
	openssl req -config "/root/ca/openssl_root.cnf" -new -key "/root/ca/ocsp/private/ocsp.guardtone.com.key.pem" -out "/root/ca/ocsp/csr/ocsp.guardtone.com.csr"
fi

# Print summary
if [ -f /root/ca/private/ocsp.guardtone.com.key.pem ]; then
	printf "\n\n>> New OCSP private key:\t/root/ca/private/ocsp.guardtone.crt.pem"
fi
