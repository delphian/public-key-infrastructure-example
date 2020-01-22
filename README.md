# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

__***For HomeLab Experimentation Only***__
```
^
|
--------------------------<<<<<<<<<<<<<<<<< Did you see?
```

## Prerequisites

#### 3 Machines
 - *ub16-ca-offline*: The offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca*: Host the OCSP responder and CRL for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home*: The intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

#### On ub16-ca-offline (offline root Certificate Authority)
* Install Ubuntu Server (in our case 16)
* Remove wifi card. Unplug physical network cable. Disable CD/DVD and USB boot in BIOS. Disable Integrated wifi and bluetooth in BIOS.
  * __Never restore this machine's connection to a network__
* From non priviledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
* Enter script repository `cd public-key-infrastructure-example`
* Replace all instances of `GuardTone` with your domain name. Eg `Google` or `MyHomeLab`
  * `sed -i -- 's/GuardTone/MyHomeLab/g' *`
* Replace all instances of `guardtone` with your domain name. Eg `google` or `myhomelab`
  * `sed -i -- 's/guardtone/myhomelab/g' *`
* [Customize openssl_root.cnf](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-openssl-config-file)
* Switch to root `sudo su -`
* Execute `./root_ca_initialize.sh`
  * Create directory structure at `/root/ca`
  * Create root Certificate Authority (CA) private key and encrypt (/root/ca/private/ca.DOMAIN.key.pem)
    * (__Do not echo the contents of this file to the terminal__) (__Do not transfer over a computer network__)
    * Supply a PEM password for the root CA private key and save to a safe location
      * (__*Do not transfer over a computer network*__) (__*Do not store on a network attached device*__)
   * Create root Certificate Authority (CA) certificate and self sign with private key (/root/ca/private/ca.DOMAIN.crt.pem)
   * Create root Certificate Authority (CA) Certificate Revocation List (CRL) (/root/ca/crl/revoked.crl)

#### On ub16-ca (OCSP responder and Certficiate Revocation List host)
* Install Ubuntu Server (in our case 16) with LAMP package
* From non priviledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
* Enter script repository `cd public-key-infrastructure-example`
* Replace all instances of `GuardTone` with your domain name. Eg `Google` or `MyHomeLab`
  * `sed -i -- 's/GuardTone/MyHomeLab/g' *`
* Replace all instances of `guardtone` with your domain name. Eg `google` or `myhomelab`
  * `sed -i -- 's/guardtone/myhomelab/g' *`
* [Customize openssl_root.cnf](https://github.com/delphian/public-key-infrastructure-example/blob/master/README.md#customize-openssl-config-file)
* Switch to root `sudo su -`
* Execute `./ocsp_create_csr.sh`
  * Create directory structure at `/root/ca/ocsp`
  * Create OCSP responder host private key and encrypt (`/root/ca/ocsp/private/ocsp.DOMAIN.com.key.pem`)
    * (__Do not echo the contents of this file to the terminal__) (__Do not transfer over a computer network__)
    * Supply a PEM password for the OCSP responder host private key and save to a safe location
      * (__*Do not echo the contents of this file to the terminal*__) (__*Do not transfer over a computer network*__)
  * Create OCSP responder host Certificate Signing Request (`/root/ca/ocsp/csr/ocsp.DOMAIN.com.csr`)
* Copy the OCSP responder host Certificate Signing Request (CSR) to a usb thumbdrive
  * `cp /root/ca/ocsp/csr/ocsp.DOMAIN.com.csr /media/usb`

#### On ub16-ca-offline (offline root Certificate Authority)
* Copy the Certificate Signing Request (CSR) from the usb thumbdrive to the CSR intake
  * `cp /media/usb/ocsp.DOMAIN.com.csr /root/ca/csr`
* Execute `./root_ca_sign_ocsp_csr.sh`
  * A list of potential Certificate Signing Requests (CSRs) will be displayed.
    * Select the OCSP host Certificate Signing Request (CSR) by typing `ocsp.DOMAIN.com`, omitting the .csr file extension.
  * Sign OCSP host Certificate Signing Request (CSR) creating the OCSP host certificate (`/root/ca/certs/ocsp.DOMAIN.com.crt.pem`)
    * Supply the previously created PEM password of the root Certificate Authority (CA) private key
* Copy the OCSP responder host certificate to a usb thumbdrive
  * `cp /root/ca/certs/ocsp.DOMAIN.com.crt.pem /media/usb`
* Copy the root Certificate Authority (CA) Certificate, revocation database (index.txt), and Certificate Revocation List (CRL) to a usb thumbdrive
  * `cp /root/ca/certs/ca.DOMAIN.crt.pem /root/ca/crl/revoked.crl /root/ca/index.txt /media/usb`

#### On ub16-ca (OCSP responder and Certficiate Revocation List host)

## Customize OpenSSL Config File

#### For ub16-ca-offline (offline root Certificate Authority)
* Edit `openssl-root.cnf`
* Replace the geographic location variables with appropriate values
  * `countryName_default`             = __*US*__
  * `stateOrProvinceName_default`     = __*California*__
  * `localityName_default`            = __*Victorville*__

#### For ub16-ca (OCSP responder and Certficiate Revocation List host)


## Resources

#### Introductory Educational Articles
* [An Overview of Cryptography](https://www.cs.princeton.edu/~chazelle/courses/BIB/overview-crypto.pdf)
* [On the Differences between Hiding Information and Cryptography Techniques: An Overview](https://scialert.net/fulltextmobile/?doi=jas.2010.1650.1655)
* [Public Key Infrastructure
Overview](http://highsecu.free.fr/db/outils_de_securite/cryptographie/pki/publickey.pdf)
* [Design and Implementation of PKI (For Multi Domain
Environment)](https://pdfs.semanticscholar.org/cfb9/77539d4a214766adc3a4a56f57a5a464b9cf.pdf)
* [A Best Practice for Root CA Key Update in PKI](https://link.springer.com/content/pdf/10.1007%2F978-3-540-24852-1_20.pdf)

#### Tutorials and Walkthroughs
* [Building an OpenSSL Certificate Authority](https://devcentral.f5.com/s/articles/building-an-openssl-certificate-authority-introduction-and-design-considerations-for-elliptical-curves-27720)

#### RFCs
* [X.509 Internet Public Key Infrastructure - Online Certificate Status Protocol - OCSP](https://tools.ietf.org/html/rfc6960)

#### Software
* [X - Certificate and Key management](https://www.hohnstaedt.de/xca/)
