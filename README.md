# Public Key Infrastructure Example
An example of public key infrastructure with an offline root certificate authority on linux. A package of scripts to make setting up and maintaining an offline root certificate authority just a bit easier.

### _For HomeLab Experimentation Only_

### Machines
 - *ub16-ca-offline* Offline root Certificate Authority (CA). Running Ubuntu 16.04
 - *ub16-ca* OCSP and CRL host for the offline root Certificate Authority (CA). Running Ubuntu 16.04 w/ LAMP stack
 - *ub16-ca-home* Intermediate Certificate Authority (CA) for intranet. Running Ubuntu 16.04 w/ LAMP stack
 
## Installation

#### UB16-CA-OFFLINE
 - From non privledged user directory: `git clone https://github.com/delphian/public-key-infrastructure-example`
 - Enter repository `cd public-key-infrastructure-example`
 - Switch to root `sudo su -`
 - Setup directory structure and initial certificates `./root_ca_initialize.sh`
 - You will be asked to create a password for the root CA private key, and prompted further on for this password
