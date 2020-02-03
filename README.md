# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

__***For HomeLab Experimentation Only***__
```
^
|
--------------------------<<<<<<<<<<<<<<<<< Did you see?
```

## Prerequisites

#### 4 Boxes
<sup><sub>__The file structure is consturcted so that all scripts and services may be run on a single machine for testing purposes__</sub></sup>
 - Box __ca-offline.guardtone.com__: Offline root Certificate Authority (CA)
 - Box __ca.guardtone.com__: OCSP responder and CRL host for offline root Certificate Authority (CA)
 - Box __ca.home.guardtone.com__: Intermediate Certificate Authority (CA) for ___intranet___
 - Box __ca-public.guardtone.com__: Intermediate Certificate Authority (CA) for ___internet___
 
## Installation

### Provision All Machines
* Install Ubuntu Server 16.04 with LAMP stack and SSH server packages on all machines
* From non priviledged user directory clone and enter repository
    ```bash
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

### Box: ca-offline.guardtone.com (Offline Root Certificate Authority)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
* Execute the root Certificate Authority (CA) initialization script
    ```bash
    sudo ./root_ca_initialize.sh
    ```
  * Generates root Certificate Authority (CA) private key and encrypts
    * Supply a PEM pass phrase for the root CA private key and verify. Save to a safe location
  * Generates root Certificate Authority (CA) Certificate Signing Request (CSR) and self sign with private key (creating the actual certificate)
    * Enter the root CA private key pass phrase
    * Enter the Distinuished Name details of the certificate holder to be incorporated into the certificate:
      * __Common Name could be `GuardTone Root Certificate Authority`__
  * Generates root Certificate Authority (CA) Certificate Revocation List (CRL)
    * Enter the root CA private key pass phrase

### Box: ca.guardtone.com (OCSP Responder and Certficiate Revocation List Host)
* Execute the OCSP responder Certificate Signing Request (CSR) creation script
    ```bash
    sudo ./root_ca_create_csr_ocsp.sh
    ```
  * Generates OCSP responder private key and encrypt
    * Supply a PEM pass phrase for the OCSP responder host private key and verify. Save to a safe location
  * Generates OCSP responder Certificate Signing Request
    * Enter the OCSP responder private key pass phrase
    * Enter the Distinuished Name details of the certificate holder to be incorporated into the certificate:
      * __*Common Name must be `ocsp.guardtone.com`*__
    * Copy the OCSP responder Certificate Signing Request (CSR) to a usb thumbdrive
    ```bash
    sudo cp /root/ca/csr/ocsp.guardtone.com.csr /media/usb
    ```

### Box: ca-offline.guardtone.com (Offline Root Certificate Authority)
* Copy the Certificate Signing Request (CSR) from the usb thumbdrive to the CSR intake and execute the Certificate Signing Request (CSR) processor script
    ```bash
    sudo cp /media/usb/ocsp.guardtone.com.csr /root/ca/csr
    sudo ./root_ca_sign_csr_ocsp.sh`
    ````
  * A list of potential Certificate Signing Requests (CSRs) will be displayed.
    * Select the OCSP responder Certificate Signing Request (CSR) by typing `ocsp.guardtone.com`, omitting the .csr file extension.
  * Sign OCSP responder Certificate Signing Request (CSR) creating the __poor practice__<sup>1</sup> OCSP responder certificate
    * Supply the previously created PEM password of the root Certificate Authority (CA) private key
    * Confirm the signing, twice
* Copy the OCSP responder certificate, root Certificate Authority (CA) Certificate, revocation database (index.txt), and Certificate Revocation List (CRL) to a usb thumbdrive
    ```bash
    sudo cp /root/ca/certs/ocsp.guardtone.com.crt.pem /media/usb
    sudo cp /root/ca/certs/ca-offline.guardtone.com.crt.pem /root/ca/crl/revoked.crl /root/ca/index.txt /media/usb
    ```

### Box: ca.guardtone.com (OCSP Responder and Certficiate Revocation List Host)
* Copy the root Certificate Authority (CA) Certificate, OCSP responder Certificate, revocation database (index.txt), and Certificate Revocation List (CRL) from the usb thumbdrive
    ```bash
    sudo cp /media/usb/index.txt /root/ca
    sudo cp /media/usb/ca-offline.guardtone.com.crt.pem /media/usb/ocsp.guardtone.com.crt.pem /root/ca/certs
    ```
* Launch OpenSSL in OCSP responder mode (as root?)
    ```bash
    sudo openssl ocsp -port 127.0.0.1:2560 -text -sha256 \
    -index "/root/ca/index.txt" \
    -CA "/root/ca/certs/ca-offline.guardtone.com.crt.pem" \
    -rkey "/root/ca/private/ocsp.guardtone.com.key.pem" \
    -rsigner "/root/ca/certs/ocsp.guardtone.com.crt.pem" \
    -nrequest 1
    ```
  * Enter the OCSP responder host private key pass phrase

## Resulting File Structure

* ca-offline.guardtone.com
  * `/home/ca`
    * `private` - Private/Public key pair (of the Root CA)
    * `crs` - Certificate requests to be processed by the Root CA (Probably from intermediates or Root CA OCSP host)
    * `certs` - Certificates signed by the Root CA (Including our self signed cert)
    * `crl` - List of all certificates revoked by the Root CA
* ca.guardtone.com
  * `/home/ca/ocsp`
    * `private` - Private/Public key pair (of OCSP host)
    * `crs` - OCSP Certificate Signing Request for presentation to the Root CA
    * `certs` - Certificates signed by the Root CA (OCSP host certificate for apache)
* ca-public.guardtone.com
  * `/home/ca/intermediate/public`
    * `private` - Private/Public key pair (of intermediate public CA)
    * `crs` - Certificate requests to be processed by intermediate public CA (Including our own request to the Root CA)
    * `certs` - Certificates signed by intermediate public CA (Including intermediate public's own certificate signed by Root CA)
    * `crl` - List of all certificate revoked by the intermediate public CA
* ca.home.guardtone.com
  * `/home/ca/intermediate/home`
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
