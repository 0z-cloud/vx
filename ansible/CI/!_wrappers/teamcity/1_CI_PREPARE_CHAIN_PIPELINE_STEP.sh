echo %RunningOnlyQA%

RUNNING_ONLY_QA="%RunningOnlyQA%"

echo "RUNNING_ONLY_QA is $RUNNING_ONLY_QA"
if [ "$RUNNING_ONLY_QA" = true ]; then
  echo "RUNNING_ONLY_QA is true"
else
  echo "RUNNING_ONLY_QA is false"
fi

ls -la ./

bash -x

rm -rf ./pass.yml
rm -rf ./vault_pass.yml
rm -rf ./ci_vault.sh

echo "##teamcity[setParameter name='dep.vortex_Main.A_DEPLOY_PASSWORD' value='%A_DEPLOY_PASSWORD%'"
echo "##teamcity[setParameter name='dep.vortex_Main.A_VAULT_PASSWORD' value='%A_VAULT_PASSWORD%'"

echo "##teamcity[setParameter name='dep.vortex_Main.env.A_DEPLOY_PASSWORD' value='%A_DEPLOY_PASSWORD%'"
echo "##teamcity[setParameter name='dep.vortex_Main.env.A_VAULT_PASSWORD' value='%A_VAULT_PASSWORD%'"

A_DEPLOY_PASSWORD="%A_DEPLOY_PASSWORD%"
A_VAULT_PASSWORD="%A_VAULT_PASSWORD%"

A_DEPLOY_PASSWORD_DEC="%A_DEPLOY_PASSWORD%"
A_VAULT_PASSWORD_DEC="%A_VAULT_PASSWORD%"

echo "A_DEPLOY_PASSWORD_DEC: $A_DEPLOY_PASSWORD_DEC"
echo "A_DEPLOY_PASSWORD: $A_DEPLOY_PASSWORD"

echo "A_VAULT_PASSWORD_DEC: $A_VAULT_PASSWORD_DEC"
echo "A_VAULT_PASSWORD: $A_VAULT_PASSWORD"

echo "%A_DEPLOY_PASSWORD%" >> ./pass.yml
echo "%A_VAULT_PASSWORD%" >> ./vault_pass.yml
echo "A_DEPLOY_PASSWORD=%A_DEPLOY_PASSWORD%" >> ./ci_vault.sh
echo "A_VAULT_PASSWORD=%A_VAULT_PASSWORD%" >> ./ci_vault.sh

chmod +x ./ci_vault.sh

ls -la ./