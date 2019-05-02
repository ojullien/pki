# PKI

Openssl wrapper script.

## Table of Contents

[Installation](#installation) | [Features](#features) | [Documentation](#documentation) | [Test](#test) | [Contributing](#contributing) | [License](#license)

## Installation

Require a Debian wheezy version of linux, a Bash version ~4.0 and OpenSSL 1.0.1e

1. [Download a release](https://github.com/ojullien/pki/releases) or clone this repository.
2. Check out and edit each configuration file in [config folder](https://github.com/ojullien/pki/tree/master/src/script/config).
3. Run the script you want. In [Script](https://github.com/ojullien/pki/tree/master/src/script) folder run `./<app_name>.sh` or `bash <app_name>.sh`.

All the scripts can take, at least, the following options:

- `-a` Create a request, a PKCS#8 key and sign the certificate.
- `-b` Store the key and the certificate in a PKCS#12 archive file format.
- `-c` Convert the key from PKCS#8 to PKCS#1 format.
- `-p` Publish the certificate in DER format."
- `-r` Create a list of revoked certificates."
- `-s` Sign the certificate from the key."
- `-v` verbose mode. Contents are displayed."

## Features

- client.sh: Generation of client certificates for TLS-authentication
- reset.sh: Create and operate Public Key Infrastructures.
- revoke.sh: Revoke certificate.
- root-ca.sh: Generation of Root CA and its CA certificate.
- server.sh: eneration of server certificates for TLS-authentication
- tls-ca.sh: Generation of a signing CA and its CA certificate

## Documentation

I wrote and I use these scripts for my own projects. And, unfortunately, I do not provide exhaustive documentation. Please read the code and the comments ;)

## Test

No test files, I'm sorry.

## Contributing

Thanks you for taking the time to contribute. Please fork the repository and make changes as you'd like.

As I use these scripts for my own projects, it contains only the features I need. But If you have any ideas, just open an [issue](https://github.com/ojullien/pki/issues/new) and tell me what you think. Pull requests are also warmly welcome.

If you encounter any **bugs**, please open an [issue](https://github.com/ojullien/pki/issues/new).

Be sure to include a title and clear description,as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

## License

This project is open-source and is licensed under the [Apache-2.0 License](https://github.com/ojullien/pki/blob/master/LICENSE).
