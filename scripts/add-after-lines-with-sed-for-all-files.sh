for file in *.conf; do
    if [ -f "$file" ]; then
        sed -i '5r /dev/stdin' "$file" <<'EOT'
	add_header X-Content-Type-Options "nosniff" always;
	add_header Referrer-Policy "no-referrer-when-downgrade" always;
	add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
	add_header X-Frame-Options "SAMEORIGIN" always;
	add_header Content-Security-Policy "default-src 'self';
						script-src 'self' 'unsafe-eval';
						style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
						img-src 'self';
						font-src 'self' https://fonts.gstatic.com;
						frame-ancestors 'self';
						form-action 'self';
						upgrade-insecure-requests;" always;
	add_header Cross-Origin-Embedder-Policy "require-corp" always;
	add_header Cross-Origin-Opener-Policy "same-origin" always;
	add_header Cross-Origin-Resource-Policy "cross-origin" always;
	ssl_protocols TLSv1.2 TLSv1.3;
EOT
    fi
done

