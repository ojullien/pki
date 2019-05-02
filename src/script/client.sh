#!/bin/sh

## -----------------------------------------------------------------------------
## openssl.
## Generation of client certificates for TLS-authentication
##
## @category  openssl
## @package   TLS Certificate
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
. "./include/option.inc"

## -----------------------------------------------------------------------------
## Loads common configuration
## -----------------------------------------------------------------------------
. "./config/main.cnf"
. "./config/root-ca.cnf"
. "./config/tls-ca.cnf"

## -----------------------------------------------------------------------------
## Loads common configuration
## -----------------------------------------------------------------------------
m_CLIENT_CONFIG=$m_DIR_CONFIG/openssl/mysql/client.cnf
m_CLIENT_KEY=$m_DIR_CA/private/client.key
m_CLIENT_PKCS1=$m_DIR_CA/private/client.pkcs1.key
m_CLIENT_CERT=$m_DIR_CRT/client.crt
m_CLIENT_CSR=$m_DIR_CSR/client.csr
m_CLIENT_DER=$m_DIR_CRT/client.cer
m_CLIENT_P12=$m_DIR_CRT/client.p12
m_CLIENT_PEM=$m_DIR_CRT/client-chain.pem
m_CLIENT_PWD=wheezy.mysql.client

display "-----------------------------------------------------"
notice " TLS CLIENT Configuration:"
checkFile "\tConfiguration file is:\t\t${m_CLIENT_CONFIG}"     $m_CLIENT_CONFIG
checkFile "\tCertificate signing request is:\t${m_CLIENT_CSR}" $m_CLIENT_CSR
checkFile "\tPrivate key file is:\t\t${m_CLIENT_KEY}"          $m_CLIENT_KEY
checkFile "\tPrivate PKCS1 key file is:\t${m_CLIENT_PKCS1}"    $m_CLIENT_PKCS1
checkFile "\tCertificate is:\t\t\t${m_CLIENT_CERT}"            $m_CLIENT_CERT
checkFile "\tCertificate chain is:\t\t${m_CLIENT_PEM}"         $m_CLIENT_PEM
checkFile "\tPublished certificate is:\t${m_CLIENT_DER}"       $m_CLIENT_DER
checkFile "\tP12 certificate is:\t\t${m_CLIENT_P12}"           $m_CLIENT_P12
pause

## -----------------------------------------------------------------------------
## Create request and key
##    With the openssl req -new command we create a private key and a
##    certificate signing request (CSR).
##    The openssl req command takes its configuration from the [req] section of
##    the configuration file.
##    This process produces two files as output:
##      1- A private key
##      2- A certificate signing request
##    These files should be kept. When the certificate you are about to create
##    expires, the request can be used again to create a new certificate with a
##    new expiry date.
##    The private key is of course necessary for SSL encryption.
## -----------------------------------------------------------------------------
if [ "${m_OPTION_KEY}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Creates request and key"

    createRequest $m_CLIENT_CONFIG \
                  $m_CLIENT_CSR \
                  $m_CLIENT_KEY \
                  -passout pass:$m_CLIENT_PWD
fi

isExist "Request" $m_CLIENT_CSR
isExist "PKCS#8 Key" $m_CLIENT_KEY
checkKey $m_CLIENT_KEY -passin pass:$m_CLIENT_PWD
pause

## -----------------------------------------------------------------------------
## Convert the key from PKCS#8 to PKCS#1 format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_PKCS1}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Convert the key from PKCS#8 to PKCS#1 format"

    convertToPKCS1 $m_CLIENT_KEY $m_CLIENT_PKCS1 -passin pass:$m_CLIENT_PWD -passout pass:$m_CLIENT_PWD
fi

isExist "PKCS#1 Key" $m_CLIENT_PKCS1
#checkKey $m_CLIENT_PKCS1 -passin pass:$m_CLIENT_PWD
checkKey $m_CLIENT_PKCS1
pause

## -----------------------------------------------------------------------------
## Display request information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewRequest $m_CLIENT_CSR
    pause
fi

## -----------------------------------------------------------------------------
## Create certificate
##    With the openssl ca command we issue a certificate based on the CSR.
##    The command takes its configuration from the [ca] section of the
##    configuration file. Note that it is the signing CA that issues the client
##    certificate!
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create certificate"

    createCertificate $m_CA_TLS_CONFIG \
                      $m_CLIENT_CSR \
                      $m_CA_TLS_KEY \
                      $m_CLIENT_CERT \
                      "client_ext" \
                      -passin pass:$m_CA_TLS_PWD \
                      -policy extern_pol
fi

isExist "Certificate" $m_CLIENT_CERT
openssl verify -policy_check -x509_strict -purpose sslclient -CAfile $m_CA_ROOT_CERT -untrusted $m_CA_TLS_CERT $m_CLIENT_CERT
pause

## -----------------------------------------------------------------------------
## Display certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewCertificate $m_CLIENT_CERT
    pause
fi

## -----------------------------------------------------------------------------
## Create PEM bundle
## -----------------------------------------------------------------------------
if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Create a certificate chain file"

    cat $m_CLIENT_KEY $m_CLIENT_CERT $m_CA_TLS_CERT $m_CA_ROOT_CERT > $m_CLIENT_PEM
fi

isExist "Chain" $m_CLIENT_PEM
openssl verify -policy_check -x509_strict -purpose sslclient -CAfile $m_CA_ROOT_CERT -untrusted $m_CA_TLS_CERT $m_CLIENT_PEM
pause

## -----------------------------------------------------------------------------
## Publish certificate in DER format
## -----------------------------------------------------------------------------
if [ "${m_OPTION_DER}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Publish certificate in DER format"

    publishCertificate $m_CLIENT_CERT $m_CLIENT_DER
fi

isExist "DER certificate" $m_CLIENT_DER
pause

## -----------------------------------------------------------------------------
## Bundle Certificate, key and the CA chain for distribution
## -----------------------------------------------------------------------------
if [ "${m_OPTION_P12}" -eq "1" ]; then
    display "-----------------------------------------------------"
    notice "Bundle certificate and key"

    openssl pkcs12 -export \
                   -name "Wheezy MySQL Client" \
                   -caname "Wheezy TLS CA" \
                   -caname "Wheezy Root CA" \
                   -inkey $m_CLIENT_KEY \
                   -in $m_CLIENT_CERT \
                   -certfile $m_CA_TLS_PEM \
                   -passin pass:$m_CLIENT_PWD \
                   -passout pass:$m_CLIENT_PWD \
                   -out $m_CLIENT_P12
fi

isExist "Bundle" $m_CLIENT_P12
pause

## -----------------------------------------------------------------------------
## Display P12 certificate information
## -----------------------------------------------------------------------------
if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "-----------------------------------------------------"
    viewP12 $m_CLIENT_P12 -passin pass:$m_CLIENT_PWD
    pause
fi
