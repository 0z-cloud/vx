
server {
        listen   10.1.1.192:9090; ## listen for ipv4; this line is default and implied # processing.vortex.com for ruru with auth cert
        #listen   [::]:80 default ipv6only=on; ## listen for ipv6

        root /var/www;
        index index.html index.htm;
        ssl on;
	ssl_certificate /srv/ssl/keystore/rootCARuru.crt;
        ssl_certificate_key /srv/ssl/keystore/rootCARuru.key;
	ssl_client_certificate /srv/ssl/keystore/rootCARuru.crt;
	ssl_verify_client on;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1.2 TLSv1.1;
        #ssl_ciphers AES256-SHA:AES128-SHA:AES128-GCM-SHA256:ECDH-ECDSA-AES128-GCM-SHA256:ECDH-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:AES256-GCM-SHA384:ECDH-ECDSA-AES256-GCM-SHA384:ECDH-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:DHE-DSS-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
	ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:AES256-SHA:AES128-SHA;
        ssl_prefer_server_ciphers on;
        # Make site accessible from http://localhost/
	server_name processing.vortex.com;
	access_log /var/log/nginx/ruru-processing.vortex.com.access.log main;
	error_log /var/log/nginx/ruru-processing.vortex.com.error.log;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to index.html
                # try_files $uri $uri/ /index.html;
		proxy_pass http://proc.vortex.co:8080/processing_service/IncomingRequestRuruModule/;
                #proxy_redirect http://10.1.0.3:8080/front_web/messenger;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
                proxy_set_header X-Real-IP $remote_addr;
        }
        location ~ /\.ht {
                deny all;
        }
}