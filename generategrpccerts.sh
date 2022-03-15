    mypass="pass123"

    echo Generate server key:
    openssl genrsa -passout pass:$mypass -des3 -out tls.key 4096

    echo Generate server signing request:
    openssl req -passin pass:$mypass -new -key tls.key -out server.csr -subj  "/C=TR/ST=TR/L=Istanbul/O=LNSwap/OU=provider/CN=localhost"

    echo Self-sign server certificate:
    openssl x509 -req -passin pass:$mypass -days 2365 -in server.csr -signkey tls.key -set_serial 01 -out tls.cert

    echo Remove passphrase from server key:
    openssl rsa -passin pass:$mypass -in tls.key -out tls.key

    rm server.csr
