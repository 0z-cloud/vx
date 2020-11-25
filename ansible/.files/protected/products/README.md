# That folder contain products with users crendentials profile vault storage link

  * Explane the Example user configuration folder layout witch store necessary environments settings and API Clouds providers connections crendentials per that user

    ```
       id_rsa                       - user private ssh-key file
       id_rsa.pub                   - user public ssh-key file
       pass.yml                     - file store primary user ssh connection password
       vault-password-file.yml      - used by CI/CD pipeline wrappers on exec set of playbooks
       vault-cloud.yml              - settings for adapter and users crendentials 
       
    ```