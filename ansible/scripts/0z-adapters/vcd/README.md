# vCloud Director 0z-Cloud Inventory Dynamic Adapter

   I. If you have some troubles, with valid requests to https:// which published with good,
     who really not expired sertificate and service API published to internet, but sometimes vCloud Director send response callback to ansible, then
     ansible stop currently running proccess, because connection is not fully trusted and insecured. 
     For disable checking that you need to say about that to urllib3 via python cli, and/or export environment variable:

         - Simple way say directly to urllib3 library via python cli about configuration changes, command for that bellow:

                  ```
                     #!/usr/bin/python3

                     import urllib3
                     urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
                     exit()

                  ```

         - For export and apply needed changes by environment variable - execute that command:

                     ```
                        export PYTHONWARNINGS="ignore:Unverified HTTPS request"

                     ````

   II. Unfourchently for Mac OS X it looks like default behavior when you use urllib3 via ansible,
      for fixing that go to documentation page of library where contains some methods and workarounds for prevention this issue.
             
                     ```
                        https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings

                     ````