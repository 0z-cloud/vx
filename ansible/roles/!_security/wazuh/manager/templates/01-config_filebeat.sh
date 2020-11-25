#!/bin/bash
# Wazuh App Copyright (C) 2019 Wazuh Inc. (License GPLv2)

set -e

WAZUH_FILEBEAT_MODULE={{ wazuh_manager.filebeat_module }}

# Install Wazuh Filebeat Module

curl -s "https://packages.wazuh.com/3.x/filebeat/${WAZUH_FILEBEAT_MODULE}" | tar -xvz -C /usr/share/filebeat/module
mkdir -p /usr/share/filebeat/module/wazuh
chmod 755 -R /usr/share/filebeat/module/wazuh