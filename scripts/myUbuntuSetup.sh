sudo apt update -y
sudo apt upgrade -y

sudo apt install net-tools vim vlc tmux -y

echo 'alias tmuxa="tmux attach-session -t"
alias azurepsqldb='PGPASSWORD=thepassword psql "--host=dbname.postgres.database.azure.com" "--port=5432" "--dbname=mydbname" "--username=myusername" "--set=sslmode=require"'
alias mbluat="sshpass -p theServerPwS ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@192.168.1.1"
alias myip="curl ident.me -4"' >> ~/.bashrc

alias mblvpn="tmux new-session -d -s mblvpn 'sudo openfortivpn -c /etc/forticlient/config'"
source ~/.bashrc
