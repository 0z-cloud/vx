<VirtualHost 10.1.1.251:1443>

    ServerName messenger.vortex.com

    SSLEngine on
    SSLCompression off
    SSLCipherSuite "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA"
    SSLHonorCipherOrder on
    SSLProtocol +TLSv1.2 +TLSv1.1 +TLSv1
    SSLCertificateFile /srv/ssl/cert-vortex.com/ca_wildcard.vortex.com.crt
    SSLCertificateKeyFile /srv/ssl/cert-vortex.com/wildcard.vortex.com.key

    # HSTS SSL security settings
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"

    ErrorLog /var/log/apache2/messenger.vortex.com.error.log
    CustomLog /var/log/apache2/messenger.vortex.com.access.log combined
    CustomLog /var/log/apache2/messenger.vortex.com.access_ssl.log sslaccesslog

    ProxyPreserveHost On
    <Proxy *>
      Order deny,allow
      Allow from all
    </Proxy>

    ProxyPass / http://10.1.0.30:8080/front_web/messenger/
    ProxyPassReverse / http://10.1.0.30:8080/front_web/messenger/

</VirtualHost>