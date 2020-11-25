## Configure IOS Devices ##

The following configuration needs to added to Cisco IOS devices:

    ! These commands must be in the IOS config
    aaa new-model
    aaa authentication fail-message ^C

    Authentication failure. This incident has been logged.

    ^C

    ! Authentication configuration
    aaa authentication password-prompt "LOCAL Password: "
    aaa authentication username-prompt "LOCAL Username: "
    aaa authentication login default group tacacs+ local
    aaa authentication enable default group tacacs+ enable

    ! Authorization configuration
    aaa authorization config-commands
    aaa authorization exec default group tacacs+ local
    aaa authorization commands 1 default group tacacs+ local
    aaa authorization commands 15 default group tacacs+ local

    ! Accounting Configuration
    aaa accounting send stop-record authentication failure
    aaa accounting exec default start-stop group tacacs+
    aaa accounting commands 1 default start-stop group tacacs+
    aaa accounting commands 15 default start-stop group tacacs+

    ! Specify a source interface that matches the TACACS ACL
    ip tacacs source-interface [interface]

    ! TACACS server config for IOS < 15
    tacacs-server host [ip] key [key]

    ! TACACS server config for IOS >= 15
    tacacs server TACACS+
     address ipv4 [ip]
     key 0 [key]
     single-connection

## Cisco N5K Devices ##

    ! Enable TACACS+
    feature tacacs+

    ! Specify TACACS+ server address and key
    tacacs-server host [ip] key [key]

    ! Specify TACACS server IP and source interface
    aaa group server tacacs+ TACACS
        server [ip]
        ip tacacs source-interface [Interface]

    ! Authentication configuration
    aaa authentication login default group TACACS local
    aaa authentication login console group TACACS local
    aaa authentication login ascii-authentication

    ! Authorization configuration
    aaa authorization config-commands default group TACACS local
    aaa authorization commands default group TACACS local

    ! Accounting Configuration
    aaa accounting default group TACACS local


## Cisco ASA Devices ##

    ! ACL for management access
    access-list TACACSLOGIN extended permit tcp [ip] [mask] interface inside eq ssh
    access-list TACACSLOGIN extended permit tcp [ip] [mask] interface inside eq https
    access-list TACACSLOGIN extended permit tcp [ip] [mask] interface inside eq ssh
    access-list TACACSLOGIN extended permit tcp [ip] [mask] interface inside eq https

    aaa-server TACACS+ protocol tacacs+
    aaa-server TACACS+ (Inside) host [ip] [key]

    aaa authentication enable console TACACS+
    aaa authentication ssh console TACACS+
    aaa authentication http console TACACS+
    aaa authentication serial console TACACS+
    aaa authentication telnet console TACACS+
    aaa authentication match TACACSLOGIN manage TACACS+

    aaa authorization command TACACS+

    aaa accounting command TACACS+
    aaa accounting enable console TACACS+
    aaa accounting ssh console TACACS+
    aaa accounting http console TACACS+
    aaa accounting serial console TACACS+
    aaa accounting telnet console TACACS+


## Cisco PIX Devices ##

    aaa-server TACACS+ protocol tacacs++
    aaa-server TACACS+ (inside) host [ip] [key]
    aaa authentication ssh console TACACS+
    aaa authentication telnet console TACACS+
    aaa authentication enable console TACACS+
    ! PIX does not support multiple authentication methods
    ! Requiring AAA server authentication from the serial console is more
    ! secure, but will result in a higher likelihood of being locked out
    ! of the device
    aaa authentication serial console TACACS+
    aaa accounting include tcp/22 inside 0 0 0 0 TACACS+
    aaa authorization command TACACS+
