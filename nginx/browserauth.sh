echo -n 'admin:' >> /etc/nginx/conf.d/.htpasswd

openssl passwd -apr1 >> /etc/nginx/conf.d/.htpasswd

And add this part in conf file

auth_basic "Restricted Content";
                 auth_basic_user_file /etc/nginx/conf.d/.htpasswd;
