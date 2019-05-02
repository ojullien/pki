## -----------------------------------------------------------------------------
## openssl.
## openssl functions
##
## @category  openssl
## @package   Includes
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## Database files
## The files must exist before the openssl ca command can be used.
## -----------------------------------------------------------------------------

createDatabases () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: createDatabases <CA database directory> <CA name>"
        exit 1
    fi
    display -n "Creating ${1}/${2} databases :"
    cp /dev/null "${1}/${2}.db"
    cp /dev/null "${1}/${2}.db.attr"
    echo 01 > "${1}/${2}.crt.srl"
    echo 01 > "${1}/${2}.crl.srl"
    displaySuccess "OK"
}

## -----------------------------------------------------------------------------
## Generates a new certificate request and a new RSA private key using
## information specified in the configuration file.
## -----------------------------------------------------------------------------

createRequest () {
    if [ $# -lt 3 -o -z "$1" -o -z "$2" -o -z "$3" ]; then
        error "Usage: createsRequest <configuration file> <certificate signing request> <private key> [-passout arg]"
        exit 1
    fi
    openssl req -new \
                -config $1 \
                -out $2 \
                -keyout $3 \
                -outform PEM $4 $5
    return $?
}

## -----------------------------------------------------------------------------
## Signes a certificate request using a RSA private key and information
## specified in the configuration file.
## -----------------------------------------------------------------------------

createCertificate () {
    if [ $# -lt 5 -o -z "$1" -o -z "$2" -o -z "$3"  -o -z "$4" -o -z "$5" ]; then
        error "Usage: createsCertificate <configuration file> <certificate signing request to be signed> <private key to sign requests with> <certificate> <section of the configuration file containing certificate extensions> [-selfsign] [-key password] [-policy arg]"
        exit 1
    fi
    openssl ca -config $1 \
               -in $2 \
               -keyfile $3 \
               -keyform PEM \
               -out $4 \
               -extensions $5 $6 $7 $8 $9 $10
    return $?
}

## -----------------------------------------------------------------------------
## All published certificates must be in DER format.
## -----------------------------------------------------------------------------

publishCertificate () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: publishCertificate <input filename to read a certificate from> <output filename to write to>"
        exit 1
    fi
    openssl x509 -inform PEM -outform DER -in $1 -out $2
    return $?
}

## -----------------------------------------------------------------------------
## Pack the private key and the certificate into a PKCS#12 bundle
## -----------------------------------------------------------------------------

bundleCertificate () {
    if [ $# -lt 6 -o -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" -o -z "$6" ]; then
       error "Usage: bundleCertificate <friendly name> <filename to read certificates and private keys from> <file to read private key from> <password source> <pass phrase source to encrypt any outputted private keys with> <filename to write>"
        exit 1
    fi
    openssl pkcs12 -export \
                   -name "$1" \
                   -in $2 \
                   -inkey $3 \
                   -passin $4 \
                   -passout $5 \
                   -out $6
    return $?
}

## -----------------------------------------------------------------------------
## Create a list of revoked certificates
##    With the openssl ca -gencrl command we generate an
##    initial (empty) CRL
##    With the openssl crl command we generate a CRL in DER format
## -----------------------------------------------------------------------------

createCRL () {
    if [ $# -lt 3 -o -z "$1" -o -z "$2" -o -z "$3" ]; then
        error "Usage: createCRL <configuration file> <private key to sign certificate with> <certificate revocation list>"
        exit 1
    fi

    openssl ca -gencrl \
               -config $1 \
               -keyfile $2 \
               -out $3 $4 $5

    openssl crl -in $3 \
                -out $3 \
                -outform der

    return $?
}

## -----------------------------------------------------------------------------
## Revokes a certificate
## -----------------------------------------------------------------------------

revokeCertificate () {
    if [ $# -lt 3 -o -z "$1" -o -z "$2" -o -z "$3" ]; then
        error "Usage: revokeCertificate <configuration file> <certificate to revoke> <revocation reason>"
        exit 1
    fi
    openssl ca -config $1 \
               -revoke $2 \
               -crl_reason $3 $4 $5
    return $?
}

## -----------------------------------------------------------------------------
## Converts the RSA key from PKCS #8 (OpenSSL 1.0 and newer) to the old PKCS #1
## format .
## Mysql 5.5 needs key in PKCS #1 format.
## -----------------------------------------------------------------------------

convertToPKCS1 () {
    if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
        error "Usage: removePassphrase <input filename to read a key from> <output filename to write a key to> [-passin arg] [output file pass phrase source]"
        exit 1
    fi
    openssl rsa -inform PEM \
                -outform PEM \
                -in $1\
                -out $2 $3 $4 $5 $6
    return $?
}

## -----------------------------------------------------------------------------
## Display the contents of CSR file in a human-readable output format
## -----------------------------------------------------------------------------

viewRequest () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: viewRequest <CSR file> "
        exit 1
    fi
    if [ -f $1 ]; then
        openssl req -noout -text -verify -in $@
    fi
    return $?
}

## -----------------------------------------------------------------------------
## Verify key consistency
## -----------------------------------------------------------------------------

checkKey () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: checkKey <input file>"
        exit 1
    fi
    if [ -f $1 ]; then
        openssl rsa -noout -check -in $@
    fi
    return $?
}

## -----------------------------------------------------------------------------
## Display the contents of a certificate file in a human-readable output format
## -----------------------------------------------------------------------------

viewCertificate () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: viewCertificate <certificate> "
        exit 1
    fi
    if [ -f $1 ]; then
        openssl x509 -noout -text -purpose -in $@
    fi
    return $?
}

viewCRL () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: viewCRL <CRL file>"
        exit 1
    fi
    if [ -f $1 ]; then
        openssl crl -noout -text -inform DER -in $@
    fi
    return $?
}

viewP12 () {
    if [ $# -lt 1 -o -z "$1" ]; then
        error "Usage: viewP12 <P12 certificate>"
        exit 1
    fi
    if [ -f $1 ]; then
        openssl pkcs12 -nodes -info -in $@
    fi
    return $?
}
