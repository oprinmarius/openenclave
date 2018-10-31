# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
set(DATA_DIR "../data")
set(S_DATA_DIR "../data")
add_executable(hostcrypto 
    main.c
    ../asn1_tests.c
    ../crl_tests.c
    ../ec_tests.c
    ../hash.c
    ../random_tests.c
    ../rsa_tests.c
    ../sha_tests.c
    ../tests.c)

add_custom_command(TARGET hostcrypto
COMMAND rm -rf ${CMAKE_CURRENT_BINARY_DIR}/${DATA_DIR}
COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${DATA_DIR}
COMMAND ${CMAKE_COMMAND} -E copy  ${CMAKE_CURRENT_SOURCE_DIR}/${S_DATA_DIR}/intermediate.cnf ${CMAKE_CURRENT_BINARY_DIR}/${DATA_DIR}/intermediate.cnf
COMMAND ${CMAKE_COMMAND} -E copy  ${CMAKE_CURRENT_SOURCE_DIR}/${S_DATA_DIR}/root.cnf ${CMAKE_CURRENT_BINARY_DIR}/${DATA_DIR}/root.cnf
COMMAND openssl genrsa -out ${DATA_DIR}/RootCA.key.pem
COMMAND openssl req -new -x509 -key ${DATA_DIR}/RootCA.key.pem -out ${DATA_DIR}/RootCA.crt.pem -days 3650 -subj "/C=US/ST=Ohio/L=Columbus/O=Acme Company/OU=Acme/CN=Root" 
# Creating Intermediate certificates signed by the Root CA
COMMAND sleep 1
COMMAND echo 'Creating Intermediate certificates signed by the root CA....'
COMMAND openssl genrsa -out ${DATA_DIR}/Intermediate.key.pem
COMMAND openssl req -new -key ${DATA_DIR}/Intermediate.key.pem -out ${DATA_DIR}/Intermediate.csr -subj "/C=US/ST=Ohio/L=Columbus/O=Acme Company/OU=Acme/CN=Intermediate"
COMMAND openssl x509 -req -in ${DATA_DIR}/Intermediate.csr -CA ${DATA_DIR}/RootCA.crt.pem -CAkey ${DATA_DIR}/RootCA.key.pem -CAcreateserial -out ${DATA_DIR}/Intermediate.crt.pem -days 3650
# Creating Leaf certificates signed by the Root CA
COMMAND sleep 1
COMMAND echo 'Creating Leaf certificates signed by the root CA....'
COMMAND openssl genrsa -out ${DATA_DIR}/Leaf.key.pem
COMMAND openssl req -new -key ${DATA_DIR}/Leaf.key.pem -out ${DATA_DIR}/Leaf.csr -subj "/C=US/ST=Ohio/L=Columbus/O=Acme Company/OU=Acme/CN=Leaf"
COMMAND openssl x509 -req -in ${DATA_DIR}/Leaf.csr -CA ${DATA_DIR}/RootCA.crt.pem -CAkey ${DATA_DIR}/RootCA.key.pem -CAcreateserial -out ${DATA_DIR}/Leaf.crt.pem -days 3650

#  Setup Certificate Revocation lists for the following test cases
#  intermediade_crl is issued by Intermediade which revokes leaf cert
#  root_crl is issued by Root which revokes leaf cert

COMMAND touch intermediate_index.txt
COMMAND touch root_index.txt
COMMAND echo "00" > intermediate_crl_number
COMMAND echo "00" > root_crl_number

COMMAND openssl ca -gencrl -config ${DATA_DIR}/intermediate.cnf -out ${DATA_DIR}/intermediate_crl.pem
COMMAND openssl ca -gencrl -config ${DATA_DIR}/root.cnf -out ${DATA_DIR}/root_crl.pem

COMMAND openssl ca -revoke ${DATA_DIR}/Leaf.crt.pem -keyfile ${DATA_DIR}/Intermediate.key.pem -cert ${DATA_DIR}/Intermediate.crt.pem -config ${DATA_DIR}/intermediate.cnf
COMMAND openssl ca -revoke ${DATA_DIR}/Leaf.crt.pem -keyfile ${DATA_DIR}/RootCA.key.pem -cert ${DATA_DIR}/RootCA.crt.pem -config ${DATA_DIR}/root.cnf

COMMAND openssl ca -gencrl -config ${DATA_DIR}/intermediate.cnf -out ${DATA_DIR}/intermediate_crl.pem
COMMAND openssl ca -gencrl -config ${DATA_DIR}/root.cnf -out ${DATA_DIR}/root_crl.pem

COMMAND openssl crl -inform pem -outform der -in ${DATA_DIR}/intermediate_crl.pem -out ${DATA_DIR}/intermediate_crl.der
COMMAND openssl crl -inform pem -outform der -in ${DATA_DIR}/root_crl.pem -out ${DATA_DIR}/root_crl.der

# Take UTC date and time of intermediate_crl for _test_get_dates
COMMAND sleep 1
COMMAND date -u +%Y:%m:%d:%H:%M:%S -r ${DATA_DIR}/intermediate_crl.der > ${DATA_DIR}/time.txt

)
target_link_libraries(hostcrypto oehost)

add_test(tests/crypto/host hostcrypto)
