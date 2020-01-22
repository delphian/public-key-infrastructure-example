# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

### _For HomeLab Experimentation Only_

### Machines Required
 - *ub16-ca-offline*: The offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca*: The OCSP and CRL host for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home*: The intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

#### UB16-CA-OFFLINE SETUP
 * From non privledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example.git`
 * Enter repository `cd public-key-infrastructure-example`
 * Switch to root `sudo su -`
 * Execute `./root_ca_initialize.sh`
   * Create directory structure
   * Create root Certificate Authority (CA) private key and encrypt
     * Supply a PEM password for the root CA private key and save to a safe location. _Do not transmit over a computer network_. _Do not store on a network attached device_.
   * Create root Certificate Authority (CA) certificate and self sign with private key (ca.*DOMAIN*.crt.pem file)
   * Create root Certificate Authority (CA) certificate revocation list (CRL) (revoked.crl file)
