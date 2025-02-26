# VaultWarden
Vaultwarden is used to manage keyfiles, Passwords etc in encrypted form.

## Install and Deploy:
```sh
git clone http://repo.amniltech.com:99/dev-ops/vaultwarden.git
```
`Change sample enviroment and edit appropriate config`
```sh
cp database-sample.env database.env
cp vault-sample.env vault.env
```
```sh
docker stack deploy -c docker-compose.yml vaultwarden
```

## Backup:
#### Install AWS Cli
```sh
aws --version
```
`Open and change appropriate variables in Shell Script`
```sh
# give permission
chmod +x vaultwarden-backup.sh
# run the backup
./vaultwarden-backup.sh
```

