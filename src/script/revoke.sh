#!/bin/sh

## -----------------------------------------------------------------------------
## openssl.
## Revoke certificate
##
## @category  openssl
## @package   TLS CA
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

clear

## -----------------------------------------------------------------------------
## Includes
## -----------------------------------------------------------------------------
. "./include/string.inc"
. "./include/filesystem.inc"
. "./include/misc.inc"
. "./include/openssl.inc"

## -----------------------------------------------------------------------------
## Loads common configuration
## -----------------------------------------------------------------------------
. "./config/main.cnf"
. "./config/root-ca.cnf"
. "./config/tls-ca.cnf"

## -----------------------------------------------------------------------------
## Options
## -----------------------------------------------------------------------------
m_OPTION_CA=0
m_OPTION_FILE=0
m_OPTION_REASON=0

while getopts "c:f:r:" m_OPTION; do
    case $m_OPTION in
    c)
      m_OPTION_CA=$OPTARG
      ;;
    f)
      m_OPTION_FILE=$OPTARG
      ;;
    r)
      m_OPTION_REASON=$OPTARG
      ;;
    \?)
        display "Usage: `/usr/bin/basename $0` <option>"
        display "\t-c\tCA name."
        display "\t-f\tFilename containing a certificate to revoke."
        display "\t-r\tRevocation reason."
        exit 1
        ;;
    esac
done

display "-----------------------------------------------------"

if [ "$m_OPTION_CA" = "root-ca" -o "$m_OPTION_CA" = "tls-ca" ]; then
    display "CA name is:\t\t\t$m_OPTION_CA"
    if [ "$m_OPTION_CA" = "root-ca" ]; then
        m_CONFIG=$m_CA_ROOT_CONFIG
        m_PWD=$m_CA_ROOT_PWD
        m_KEY=$m_CA_ROOT_KEY
    else
        m_CONFIG=$m_CA_TLS_CONFIG
        m_PWD=$m_CA_TLS_PWD
        m_KEY=$m_CA_TLS_KEY
    fi
     m_CRL=$m_DIR_CRL/$m_OPTION_CA.crl
else
    error "CA name is not valid:\t$m_OPTION_CA"
    exit 1
fi

m_FILE=$m_DIR_CA/archive/$m_OPTION_CA/$m_OPTION_FILE

checkFile "Certificate to revoke is:\t$m_FILE" $m_FILE
display "Revocation reason is:\t\t$m_OPTION_REASON"
checkFile "Configuration file is:\t\t$m_CONFIG" $m_CONFIG
checkFile "Private key file is:\t\t${m_KEY}" $m_KEY
checkFile "Certificate Revocation List is:\t${m_CRL}" $m_CRL
pause

## -----------------------------------------------------------------------------
## Revoke certificate
##    Certain events, like certificate replacement or loss of private key,
##    require a certificate to be revoked before its scheduled expiration date.
##    The openssl ca -revoke command marks a certificate as revoked in the CA
##    database.
##    It will from then on be included in CRLs issued by the CA.
## -----------------------------------------------------------------------------
display "-----------------------------------------------------"

revokeCertificate $m_CONFIG \
                  $m_FILE \
                  "superseded" \
                  -passin pass:$m_PWD

pause

## -----------------------------------------------------------------------------
## Create a list of revoked certificates
## -----------------------------------------------------------------------------
display "-----------------------------------------------------"

createCRL $m_CONFIG \
          $m_KEY \
          $m_CRL \
          -passin pass:$m_PWD

isExist "Revoked list" $m_CRL
pause

## -----------------------------------------------------------------------------
## Display revoked certificates list information
## -----------------------------------------------------------------------------
display "-----------------------------------------------------"
viewCRL $m_CRL
