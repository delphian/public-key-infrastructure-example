# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

__***For HomeLab Experimentation Only***__
```
^
|
--------------------------<<<<<<<<<<<<<<<<< Did you see?
```

## Prerequisites

#### 4 Boxes <sup><sub>__The file structure is constructed so that all scripts and services may be run on a single machine for testing purposes__</sub></sup>
 - Box __ca-offline.guardtone.com__: Offline root Certificate Authority (CA)
 - Box __ca.guardtone.com__: OCSP responder and CRL host for offline root Certificate Authority (CA)
 - Box __ca.home.guardtone.com__: Intermediate Certificate Authority (CA) for ___intranet___
 - Box __ca-public.guardtone.com__: Intermediate Certificate Authority (CA) for ___internet___
 
## Installation

### Provision All Machines
* Install Ubuntu Server 16.04 with SSH server packages on all machines
* From non priviledged user directory clone and enter repository
    ```bash
    sudo apt-get install apache2
    git clone https://github.com/delphian/public-key-infrastructure-example.git
    cd public-key-infrastructure-example
    ```
### Customize Variables After Cloning Repository

#### Customize All Files for your Domain
* Replace all instances of camel case `GuardTone`, and lowecase `guardtone` with your domain name
    ```bash
    sed -i -- 's/GuardTone/MyHomeLab/g' *
    sed -i -- 's/guardtone/myhomelab/g' *
    ```

#### Customize All OpenSSL Config Files
* Edit `*-openssl.cnf`
* Replace the geographic location variables with appropriate values
    ```bash
    countryName_default             = US
    stateOrProvinceName_default     = California
    localityName_default            = Victorville
    ```

### Box: ca-offline.guardtone.com (Offline Root CA)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
* Create file structure
  ```bash
  mkdir -p "/root/ca/private" "/root/ca/csr" "/root/ca/certs" "/root/ca/crl"
  touch "/root/ca/index.txt"
  echo 1000 > "/root/ca/serial"
  echo 1000 > "/root/ca/crlnumber"
  ```
* Create Root CA private key and self sign certificate. CN could be `GuardTone Root Certificate Authority`
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/private/ca-offline.guardtone.com.key.pem"
  openssl req -config "./root_ca_openssl.cnf" \
              -new -x509 -sha384 \
              -extensions v3_ca \
              -key "/root/ca/private/ca-offline.guardtone.com.key.pem" \
              -out "/root/ca/certs/ca-offline.guardtone.com.crt.pem"
  ```
* Create (or update) CRL
  ```bash
  openssl ca -config "./root_ca_openssl.cnf" -gencrl -out "/root/ca/crl/revoked.crl"
  ```

### Box: ca.guardtone.com (OCSP Responder and CRL Host)
* Create file structure
  ```bash
  mkdir -p "/root/ca/private" "/root/ca/csr" "/root/ca/certs" "/root/ca/crl"
  ```
* Create OCSP Resolver private key and CSR. ___CN must be `ocsp.ca.guardtone.com`___
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/private/ocsp.ca.guardtone.com.key.pem"
  openssl req -config "./root_ca_openssl.cnf" \
              -new \
              -key "/root/ca/private/ocsp.ca.guardtone.com.key.pem" \
              -out "/root/ca/csr/ocsp.ca.guardtone.com.csr"
  ```
* Create CRL host private key and CSR. ___CN must be `crl.ca.guardtone.com`___
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/private/crl.ca.guardtone.com.key.pem"
  openssl req -config "./root_ca_openssl.cnf" \
              -new \
              -key "/root/ca/private/crl.ca.guardtone.com.key.pem" \
              -out "/root/ca/csr/crl.ca.guardtone.com.csr"
  ```
* Copy CSRs to ca-offline.guardtone.com:/root/ca/csr

### Box: ca-offline.guardtone.com (Offline Root CA)
* Sign OCSP responder CSR creating certificate good for 14 days using `ocsp` config file options, then review certificate
  ```bash
  openssl ca -config "./root_ca_openssl.cnf" \
             -extensions ocsp \
             -days 14 \
             -md sha384 \
             -in "/root/ca/csr/ocsp.ca.guardtone.com.csr" \
             -out "/root/ca/certs/ocsp.ca.guardtone.com.crt.pem"
  openssl x509 -noout -text -in "/root/ca/certs/ocsp.ca.guardtone.com.crt.pem"
  ```
* Sign CRL host CSR creating certificate good for 14 days using `server_cert` config file options, then review certificate
  ```bash
  openssl ca -config "./root_ca_openssl.cnf" \
             -extensions server_cert \
             -days 14 \
             -md sha384 \
             -in "/root/ca/csr/crl.ca.guardtone.com.csr" \
             -out "/root/ca/certs/crl.ca.guardtone.com.crt.pem"
  openssl x509 -noout -text -in "/root/ca/certs/crl.ca.guardtone.com.crt.pem"
  ```
* Copy OCSP, CRL, and Root CA certificates to `ca.guardtone.com:/root/ca/certs`
* Copy `/root/ca/index.txt` OCSP database to `ca.guardtone.com:/root/ca`
* Copy `/root/ca/crl/revoked.crl` CRL to `ca.guardtone.com:/root/ca/crl`

### Box: ca.guardtone.com (OCSP Responder and CRL Host)
* Launch the OCSP responder with OpenSSL
  ```bash
  openssl ocsp -port 2560 -text -sha256 \
               -index "/root/ca/index.txt" \
               -CA "/root/ca/certs/ca-offline.guardtone.com.crt.pem" \
               -rkey "/root/ca/private/ocsp.ca.guardtone.com.key.pem" \
               -rsigner "/root/ca/certs/ocsp.ca.guardtone.com.crt.pem"
  ```
* Update Apache with CRL
  ```bash
  cp /root/ca/crl/revoked.crl /var/www/html/guardtone-ca-revoked.crl
  ```

### Box: ca-public.guardtone.com (Online Intermediate _Public_ CA)
* Create file structure
  ```bash
  mkdir -p "/root/ca/intermediate/public/private" \
           "/root/ca/intermediate/public/csr" \
           "/root/ca/intermediate/public/certs" \
           "/root/ca/intermediate/public/crl"
  touch "/root/ca/intermediate/public/index.txt"
  echo 1000 > "/root/ca/intermediate/public/serial"
  echo 1000 > "/root/ca/intermediate/public/crlnumber"
  ```
* Create Intermediate CA private key and CSR. ___CN could be `GuardTone Intermediate Public Certificate Authority`___
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/intermediate/public/private/ca-public.guardtone.com.key.pem"
  openssl req -config "./intermediate_ca_public_openssl.cnf" \
              -new \
              -key "/root/ca/intermediate/public/private/ca-public.guardtone.com.key.pem" \
              -out "/root/ca/intermediate/public/csr/ca-public.guardtone.com.csr"
  ```
* Copy CSRs to ca-offline.guardtone.com:/root/ca/csr

### Box: ca-offline.guardtone.com (Offline Root CA)
* Sign intermediate CA CSR creating certificate good for 3650 days using `v3_intermediate_ca` config file options, then review certificate
  ```bash
  openssl ca -config "./root_ca_openssl.cnf" \
             -extensions v3_intermediate_ca \
             -days 3650 \
             -md sha384 \
             -in "/root/ca/csr/ca-public.guardtone.com.csr" \
             -out "/root/ca/certs/ca-public.guardtone.com.crt.pem"
  openssl x509 -noout -text -in "/root/ca/certs/ca-public.guardtone.com.crt.pem"
  ```
* Copy Intermediate CA certificate to ca-public.guardtone.com:/root/ca/intermediate/public/certs

### Box: ca-public.guardtone.com (Online Intermediate _Public_ CA)
* Create OCSP CA private key and sign for 3650 days using `ocsp` config file options, then review certificate. ___CN must be `ocsp.ca-public.guardtone.com`___
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/intermediate/public/private/ocsp.ca-public.guardtone.com.key.pem"
  openssl req -config "./intermediate_ca_public_openssl.cnf" \
              -new -x509 -sha384 -extensions ocsp -days 3650 \
              -key "/root/ca/intermediate/public/private/ca-public.guardtone.com.key.pem" \
              -out "/root/ca/intermediate/public/certs/ocsp.ca-public.guardtone.com.crt.pem"
  openssl x509 -noout -text \
               -in "/root/ca/intermediate/public/certs/ocsp.ca-public.guardtone.com.crt.pem"
* Create CRL host private key and sign for 3650 days using `server_cert` config file options, then review certificate. ___CN must be `crl.ca-public.guardtone.com`___
  ```bash
  openssl ecparam -genkey -name secp384r1 \
     | openssl ec -aes256 -out "/root/ca/intermediate/public/private/crl.ca-public.guardtone.com.key.pem"
  openssl req -config "./intermediate_ca_public_openssl.cnf" \
              -new -x509 -sha384 -extensions ocsp -days 3650 \
              -key "/root/ca/intermediate/public/private/ca-public.guardtone.com.key.pem" \
              -out "/root/ca/intermediate/public/certs/crl.ca-public.guardtone.com.crt.pem"
  openssl x509 -noout -text \
               -in "/root/ca/intermediate/public/certs/crl.ca-public.guardtone.com.crt.pem"
* Create (or update) CRL
  ```bash
  openssl ca -config "./intermediate_ca_public_openssl.cnf" -gencrl \
             -out "/root/ca/intermediate/public/crl/revoked.crl"
  ```
* Launch the OCSP responder with OpenSSL
  ```bash
  openssl ocsp -port 2570 -text -sha256 \
               -index "/root/ca/intermediate/public/index.txt" \
               -CA "/root/ca/intermediate/public/certs/ca-public.guardtone.com.crt.pem" \
               -rkey "/root/ca/intermediate/public/private/ocsp.ca-public.guardtone.com.key.pem" \
               -rsigner "/root/ca/intermediate/public/certs/ocsp.ca-public.guardtone.com.crt.pem"
  ```
* Update Apache with CRL
  ```bash
  cp /root/ca/intermediate/public/crl/revoked.crl /var/www/html/guardtone-ca-public-revoked.crl
  ```

## Resulting File Structure

* `ca-offline.guardtone.com:/root/ca`
  * `private` - Private/Public key pair (of the Root CA)
  * `crs` - Certificate requests to be processed by the Root CA (Probably from intermediates or Root CA OCSP host)
  * `certs` - Certificates signed by the Root CA (Including our self signed cert)
  * `crl` - List of all certificates revoked by the Root CA
* `ca.guardtone.com:/root/ca/ocsp`
  * `private` - Private/Public key pair (of OCSP host)
  * `crs` - OCSP Certificate Signing Request for presentation to the Root CA
  * `certs` - Certificates signed by the Root CA (OCSP host certificate for apache)
* `ca-public.guardtone.com:/root/ca/intermediate/public`
  * `private` - Private/Public key pair (of intermediate public CA)
  * `crs` - Certificate requests to be processed by intermediate public CA (Including our own request to the Root CA)
  * `certs` - Certificates signed by intermediate public CA (Including intermediate public's own certificate signed by Root CA)
  * `crl` - List of all certificate revoked by the intermediate public CA
* `ca.home.guardtone.com:/root/ca/intermediate/home`
  * `private` - Private/Public key pair (of intermediate home CA)
  * `crs` - Certificate requests to be processed by intermediate home CA (Including ou own request to the Root CA)
  * `certs` - Certificates signed by intermediate home CA (Including intermediate home's own certificate signed by Root CA)
  * `crl` - List of all certificate revoked by the intermediate home CA

## Resources

### Introduction
* [An Overview of Cryptography](https://www.cs.princeton.edu/~chazelle/courses/BIB/overview-crypto.pdf)
* [On the Differences between Hiding Information and Cryptography Techniques: An Overview](https://scialert.net/fulltextmobile/?doi=jas.2010.1650.1655)
* [Public Key Infrastructure
Overview](http://highsecu.free.fr/db/outils_de_securite/cryptographie/pki/publickey.pdf)
* [Design and Implementation of PKI (For Multi Domain
Environment)](https://pdfs.semanticscholar.org/cfb9/77539d4a214766adc3a4a56f57a5a464b9cf.pdf)
* [HTTPS in the Real World](https://robertheaton.com/2018/11/28/https-in-the-real-world/)

### Tutorials and Walkthroughs
* [OCSP Validation with OpenSSL](https://akshayranganath.github.io/OCSP-Validation-With-Openssl/)
* [Building an OpenSSL Certificate Authority](https://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considerations-for-elliptical-curves-27720)

### Best Practice, Common Mistakes
* <sup>[1]</sup>[Most Secure Way to do OCSP Signing](https://security.stackexchange.com/questions/15564/what-is-the-most-secure-way-to-do-ocsp-signing-without-creating-validation-loops)
* [A Best Practice for Root CA Key Update in PKI](https://link.springer.com/content/pdf/10.1007%2F978-3-540-24852-1_20.pdf)

### RFCs
* [X.509 Internet Public Key Infrastructure - Online Certificate Status Protocol - OCSP](https://tools.ietf.org/html/rfc6960)
* [Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile](https://tools.ietf.org/html/rfc5280)

### Software
* [X - Certificate and Key management](https://www.hohnstaedt.de/xca/)
