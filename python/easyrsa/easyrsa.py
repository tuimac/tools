#!/usr/bin/env python3

from cryptography import x509
from cryptography.x509.oid import NameOID, ExtendedKeyUsageOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
import datetime
import os
import sys

# Static Variables for configuration
## Directory to dump the cert or key file
FILE_DIR = os.path.dirname(os.path.abspath(sys.argv[0]))

## Expiration(Days)
EXPIRE = 36500

## Key size
KEY_SIZE = 2048

## Common Name
COMMON_NAME = 'tuimac.com'

def create_ca_cert():
    ca_key = rsa.generate_private_key(
        public_exponent = 65537,
        key_size = KEY_SIZE,
        backend = default_backend()
    )
    ca_name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, COMMON_NAME)])
    ca_csr = x509.CertificateSigningRequestBuilder().subject_name(x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, COMMON_NAME),
    ])).add_extension(
        x509.SubjectAlternativeName([x509.DNSName(COMMON_NAME)]),
        critical=False,
    ).sign(ca_key, hashes.SHA256(), default_backend())
    ca_cert = (
        x509.CertificateBuilder()
        .subject_name(ca_name)
        .issuer_name(ca_name)
        .public_key(ca_csr.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(datetime.datetime.now(datetime.timezone.utc))
        .not_valid_after(datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days = EXPIRE))
        .add_extension(
            x509.BasicConstraints(ca=True, path_length=None),
            critical=False,
        )
        .add_extension(
            x509.SubjectKeyIdentifier.from_public_key(ca_key.public_key()),
            critical=False,
        )
        .add_extension(
            x509.AuthorityKeyIdentifier(
                key_identifier=x509.SubjectKeyIdentifier.from_public_key(ca_key.public_key()).digest,
                authority_cert_issuer=[x509.DirectoryName(ca_name)],
                authority_cert_serial_number=x509.random_serial_number(),
            ),
            critical=False,
        )
        .add_extension(
            x509.KeyUsage(
                key_cert_sign=True,
                crl_sign=True,
                digital_signature=False,
                key_encipherment=False,
                data_encipherment=False,
                content_commitment=False,
                key_agreement=False,
                encipher_only=False,
                decipher_only=False
            ),
            critical=False,
        )
        .sign(ca_key, hashes.SHA256(), default_backend())
    )
    with open(os.path.join(FILE_DIR, 'ca.crt'), 'wb') as f:
        f.write(
            ca_cert.public_bytes(encoding=serialization.Encoding.PEM)
        )
    return ca_cert, ca_key

def create_server_key():
    server_key = rsa.generate_private_key(
        public_exponent = 65537,
        key_size = KEY_SIZE,
        backend = default_backend()
    )
    with open(os.path.join(FILE_DIR, 'server.key'), 'wb') as f:
        f.write(
            server_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.TraditionalOpenSSL,
                encryption_algorithm=serialization.NoEncryption(),
            )
        )
    return server_key

def create_server_cert(ca_cert, ca_key, server_key):
    server_csr = x509.CertificateSigningRequestBuilder().subject_name(x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, COMMON_NAME),
    ])).add_extension(
        x509.SubjectAlternativeName([x509.DNSName(COMMON_NAME)]),
        critical=False,
    ).sign(server_key, hashes.SHA256(), default_backend())
    server_cert = (
        x509.CertificateBuilder()
        .subject_name(server_csr.subject)
        .issuer_name(ca_cert.issuer)
        .public_key(server_csr.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(datetime.datetime.now(datetime.timezone.utc))
        .not_valid_after(datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days = EXPIRE))
        .add_extension(
            x509.BasicConstraints(ca=True, path_length=None),
            critical=False,
        )
        .add_extension(
            x509.SubjectKeyIdentifier.from_public_key(server_key.public_key()),
            critical=False,
        )
        .add_extension(
            x509.AuthorityKeyIdentifier(
                key_identifier=x509.SubjectKeyIdentifier.from_public_key(ca_key.public_key()).digest,
                authority_cert_issuer=[x509.DirectoryName(ca_cert.subject)],
                authority_cert_serial_number=ca_cert.serial_number,
            ),
            critical=False,
        )
        .add_extension(
            x509.KeyUsage(
                digital_signature=True,
                key_encipherment=True,
                key_agreement=False,
                content_commitment=False,
                data_encipherment=False,
                key_cert_sign=False,
                crl_sign=False,
                encipher_only=False,
                decipher_only=False,
            ),
            critical=False,
        )
        .add_extension(
            x509.ExtendedKeyUsage([ExtendedKeyUsageOID.SERVER_AUTH]),
            critical=False,
        )
        .sign(ca_key, hashes.SHA256(), default_backend())
    )
    with open(os.path.join(FILE_DIR, 'server.crt'), 'wb') as f:
        f.write(
            server_cert.public_bytes(encoding=serialization.Encoding.PEM)
        )

if __name__ == '__main__':
    ca_cert, ca_key = create_ca_cert()
    server_key = create_server_key()
    create_server_cert(ca_cert, ca_key, server_key)