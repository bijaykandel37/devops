# Hashicorp Vault

After the ansible playbook is completed, the vault server is listening at 8200 port.
the default conf directory is /etc/vault.d and data directory is /opt/vault/data

Make necessary changes to vault.hcl if you need modifications

In the ui console, https://url:8200/ui is loaded which asks for key shares and threshold

`key shares` refer to the number of pieces into which Vault's master key is divided using Shamir's Secret Sharing (SSS) algorithm. Each key share is essentially a part of the master key, and these shares are distributed among the specified number of unseal key holders
`key threshold` is the minimum number of key shares required to reconstruct the original master key and thus unseal Vault

Need to set those variables to use vault command with cli,

`export VAULT_ADDR=https://127.0.0.1:8200`
`export VAULT_SKIP_VERIFY=1`

You can use this command to initialize with cli also
`vault operator init -key-shares=10 -key-threshold=3`

To unseal the vault, you need to provide the number of keys which is specified by your threshold.
To login, you can use the root_token.


When Vault is initially started or restarted, it starts in a "sealed" state. In this state, Vault's master key is not accessible and cannot be used to decrypt any stored secrets. The seal prevents unauthorized access to Vault's encrypted data

To make Vault operational and allow access to its stored secrets, it needs to be "unsealed."

Within cli. you need to execute `vault login` and then use the root_token to solve 403 errors.


To enable jwt authentication:

`vault auth enable jwt`

Or Enable a secret engine KV secrets engine v2
`vault secrets enable -path=secret kv-v2`


To store a secret in vault with cli, use the following command:

`vault kv put secret/myapp/config username='myuser' password='mypassword`




Need to create policy for above created secret with read capability:
read-secret.hcl
```
path "secret/data/myapp/config" {
  capabilities = ["read"]
}
```
Apply the policy with command:
`vault policy write read-secret read-secret.hcl`

Now generate token which will be needed for gitlab ci:
`vault token create -policy=read-secret`











