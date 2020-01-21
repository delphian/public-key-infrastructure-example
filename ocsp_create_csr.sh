# Inspired by instructions from http://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
#
# Switch to root before executing. To reset and start over first issue 'rm -Rf /root/ca'
#
# Execute on OCSP server to retain the secrecy of the ocsp private key

#
# Abort script if any error is encountered
set -e

#
# Create directory structure
if [ ! -d /root/ca ]; then
	printf "\n>> Generating /root/ca directory structure...\n"
	mkdir /root/ca
	mkdir /root/ca/private /root/ca/csr /root/ca/certs /root/ca/crl
fi

#
# Generate root ocsp responder private key and encrypt
if [ ! -f /root/ca/private/ocsp.guardtone.com.key.pem ]; then
	printf "\n>> Generating root Certificate Authority (CA) private OCSP responder key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out /root/ca/private/ocsp.guardtone.com.key.pem
fi

#
# Generate root ocsp responder Certificate Signing Request (CSR)
if [ ! -f /root/ca/csr/ocsp.guardtone.com.csr ]; then
	printf "\n>> Generating root OCSP responder Certificate Signing Request (CSR)...\n\n"
fi

#
# Print summary
if [ -f /root/ca/private/ocsp.guardtone.com.key.pem ]; then
	printf "\n\n>> New OCSP private key:\t/root/ca/private/ocsp.guardtone.crt.pem"
fi

