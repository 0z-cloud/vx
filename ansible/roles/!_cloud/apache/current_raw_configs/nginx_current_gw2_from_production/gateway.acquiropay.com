
server {
        listen   10.1.1.232:443; ## listen for ipv4; this line is default and implied
        #listen   [::]:80 default ipv6only=on; ## listen for ipv6

        root /var/www;
        index index.html index.htm;
        ssl on;
	ssl_certificate /srv/ssl/cert-vortex.com/ca_wildcard.vortex.com.crt;
	ssl_certificate_key /srv/ssl/cert-vortex.com/wildcard.vortex.com.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
	#ssl_ciphers AES256-SHA:AES128-SHA:AES128-GCM-SHA256:ECDH-ECDSA-AES128-GCM-SHA256:ECDH-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:AES256-GCM-SHA384:ECDH-ECDSA-AES256-GCM-SHA384:ECDH-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:DHE-DSS-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
	ssl_ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:AES256-SHA:AES128-SHA;
        ssl_prefer_server_ciphers on;
        # Make site accessible from http://localhost/
        server_name gateway.vortex.com;
	# workaround problem http://vexell.ru/2011/02/%D0%BC%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B1%D0%B0%D0%BD%D0%BA-callback-%D0%B8-nginx/
	# This is problem BM callback request
	proxy_ignore_client_abort on;
	access_log /var/log/nginx/gateway.vortex.com.access.log main;
        error_log /var/log/nginx/gateway.vortex.com.error.log;
        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to index.html
                # try_files $uri $uri/ /index.html;
                proxy_pass http://10.1.0.30:8080/front_web/gate/;
                #proxy_redirect http://10.1.0.3:8080/front_web/gate;
                proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For  $proxy_add_x_forwarded_for;
                proxy_set_header X-Real-IP $remote_addr;
        }
        location ~ /\.ht {
                deny all;
        }
}

<VirtualHost 10.1.1.231:443>
  ServerName gateway.vortex.com
                                                         
    SSLEngine on
    SSLCompression off
    SSLCipherSuite "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:AES256-SHA:AES128-SHA"
    SSLHonorCipherOrder on
    SSLProtocol TLSv1.1 TLSv1.2 TLSv1
    SSLCertificateFile /srv/ssl/cert-vortex.com/ca_wildcard.vortex.com.crt
    SSLCertificateKeyFile /srv/ssl/cert-vortex.com/wildcard.vortex.com.key

    ErrorLog /var/log/apache2/gateway.vortex.com.error.log
    CustomLog /var/log/apache2/gateway.vortex.com.access.log combined
    CustomLog /var/log/apache2/access_ssl.log sslaccesslog

    ProxyPreserveHost On
    <Proxy *>
      Order deny,allow
      Allow from all
    </Proxy>

    ProxyPass / http://10.1.0.30:8080/front_web/gate
    ProxyPassReverse / http://10.1.0.30:8080/front_web/gate
    ProxyPassReverseCookiePath / http://10.1.0.30:8080/front_web/gate

</VirtualHost>