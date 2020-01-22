# Inspired by instructions from https://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considertions-for-elliptical-curves-27720
# Switch to root before executing. To reset and start over first issue 'rm -Rf /root/ca'

# Abort script if any error is encountered
set -e

# Create directory structure
if [ ! -d /root/ca ]; then
	printf "\n>> Generating /root/ca directory structure...\n"
	mkdir -p /root/ca/private /root/ca/csr /root/ca/certs /root/ca/crl
	touch /root/ca/index.txt
	echo 1000 > /root/ca/serial
	echo 1000 > /root/ca/crlnumber
	cp openssl_root.cnf /root/ca/openssl_root.cnf
fi

# Generate root private key and encrypt
if [ ! -f /root/ca/private/ca.guardtone.key.pem ]; then
	printf "\n>> Generating root Certificate Authority (CA) private key and encrypting...\n\n"
	openssl ecparam -genkey -name secp384r1 | openssl ec -aes256 -out /root/ca/private/ca.guardtone.key.pem
fi

# Generate root certificate
if [ ! -f /root/ca/certs/ca.guardtone.crt.pem ]; then
	printf "\n>> Generating root CA certificate and self signing...\n\n"
	openssl req -config /root/ca/openssl_root.cnf -new -x509 -sha384 -extensions v3_ca -key /root/ca/private/ca.guardtone.key.pem -out /root/ca/certs/ca.guardtone.crt.pem
fi

# Create root Certificate Revocation List
if [ ! -f /root/ca/crl/revoked.crl ]; then
	printf "\n>> Generating root CA Certificate Revocation List (CRL)...\n\n"
	openssl ca -config /root/ca/openssl_root.cnf -gencrl -out /root/ca/crl/revoked.crl
fi

# Validate root Certificate Revocation List
if [ -f /root/ca/crl/revoked.crl ]; then
	printf "\n>> Validating root CA CRL...\n\n"
	openssl crl -in /root/ca/crl/revoked.crl -noout -text
fi

# Print summary
if [ -f /root/ca/certs/ca.guardtone.crt.pem ]; then
	printf "\n\n>> New Root CA Certificate:\t\t\t\t/root/ca/certs/ca.guardtone.crt.pem"
	printf "\n>> New Root CA Certificate Revocation List (CRL):\t/root/ca/crl/revoked.crl\n\n"
fi
