## -----------------------------------------------------
## openssl.
## script functions
##
## @category  openssl
## @package   Includes
## @license Apache-2.0 <https://github.com/ojullien/pki/blob/master/LICENSE>
## -----------------------------------------------------

m_OPTION_KEY=0
m_OPTION_CRT=0
m_OPTION_DER=0
m_OPTION_P12=0
m_OPTION_CRL=0
m_OPTION_PKCS1=0
m_OPTION_VERBOSE=0

while getopts "abcprsv?" m_OPTION; do
    case $m_OPTION in
    a)
        m_OPTION_KEY=1
        m_OPTION_CRT=1
        ;;
    s)
        m_OPTION_CRT=1
        ;;
    p)
        m_OPTION_DER=1
        ;;
    b)
        m_OPTION_P12=1
        ;;
    r)
        m_OPTION_CRL=1
        ;;
    c)
        m_OPTION_PKCS1=1
        ;;
    v)
        m_OPTION_VERBOSE=1
        ;;
    \?)
        display "Usage: `/usr/bin/basename $0` [option]"
        display "\t-a\tCreate a request, a PKCS#8 key and sign the certificate."
        display "\t-b\tStore the key and the certificate in a PKCS#12 archive file format."
        display "\t-c\tConvert the key from PKCS#8 to PKCS#1 format."
        display "\t-p\tPublish the certificate in DER format."
        display "\t-r\tCreate a list of revoked certificates."
        display "\t-s\tSign the certificate from the key."
        display "\t-v\tverbose mode. Contents are displayed."
        exit 1
        ;;
    esac
done

if [ "${m_OPTION_KEY}" -eq "1" ]; then
    display "Will create a request, a PKCS#8 key and sign the certificate."
fi

if [ "${m_OPTION_CRT}" -eq "1" ]; then
    display "Will sign the certificate from the key."
fi

if [ "${m_OPTION_DER}" -eq "1" ]; then
    display "Will publish the certificate in DER format."
fi

if [ "${m_OPTION_PKCS1}" -eq "1" ]; then
    display "Will convert the key from PKCS#8 to PKCS#1 format."
fi

if [ "${m_OPTION_P12}" -eq "1" ]; then
    display "Will store the key and the certificate in a PKCS#12 archive file format."
fi

if [ "${m_OPTION_CRL}" -eq "1" ]; then
    display "Will create a list of revoked certificate."
fi

if [ "${m_OPTION_VERBOSE}" -eq "1" ]; then
    display "Verbose mode is ON. All contents will be displayed."
else
    display "Verbose mode is OFF. No content will be displayed."
fi
