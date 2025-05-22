ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
  #tls_cert_file = "/vault/tls/tls.crt"
 # tls_key_file  = "/vault/tls/tls.key"
}

storage "file" {
  path = "/vault/file"
}

api_addr = "https://127.0.0.1:8200"

disable_mlock = "true"
