package CryptoBank_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.script

object CryptoBank_BuildChain_PrepareCi : BuildType({
    name = "1: INIT | Prepare CI"

    artifactRules = """
        ./pass.yml => ansible_prepare_result.zip
        ./super_message.yml => ansible_prepare_result.zip
        ./message.yml => ansible_prepare_result.zip
        ./vault_pass.yml => ansible_prepare_result.zip
        ./ci_vault.sh => ansible_prepare_result.zip
        ./new_pass.yml => ansible_prepare_result.zip
        ./NG_DEPLOY_PASSWORD.yml => ansible_prepare_result.zip
    """.trimIndent()
    maxRunningBuilds = 1

    params {
        param("A_DEPLOY_PASSWORD", "credentialsJSON:b2bc6c27-ec64-413a-b27c-8a32e5628dd9")
        param("ANSIBLE_CI_PROJECT_NAME", "")
        param("RunningOfferForBuild", "")
        param("ANSIBLE_REGISTRY_URL", "")
        param("ANSIBLE_RUN_TYPE", "")
        param("ANSIBLE_DEPLOY_USERNAME", "")
        param("env.reverse.dep.env.ReactivePay_Main.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
        param("RunningOfferForPublish", "")
        param("ANSIBLE_BUILD_ID", "")
        param("ANSIBLE_CI_PROJECT_NAMESPACE", "")
        password("INIT_PASS", "zxx775d03cbe80d301b", label = "INIT_PASS", description = "INIT_PASS", display = ParameterDisplay.PROMPT)
        param("ANSIBLE_COMMIT_SHA", "")
        param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
        param("ANSIBLE_VERSION", "")
        param("ANSIBLE_REGISTRY_USERNAME", "")
        param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
        param("env.reverse.dep.env.ReactivePay_Main.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
        param("A_VAULT_PASSWORD", "credentialsJSON:b2bc6c27-ec64-413a-b27c-8a32e5628dd9")
        param("MAIN_ANSIBLE_BUILD_ID", "")
        param("ANSIBLE_ENVIRONMENT", "")
        param("NG_DEPLOY_PASSWORD", "")
        param("ANSIBLE_CLOUD_TYPE", "")
        param("ANSIBLE_PRODUCT_NAME", "")
        param("A_ENV_SECURITY", "")
        param("RunningOnlyQA", "")
        param("ANSIBLE_APPLICATION_TYPE", "")
    }

    vcs {
        root(DslContext.settingsRoot)

        showDependenciesChanges = true
    }

    steps {
        script {
            name = "Prepare CI"
            scriptContent = """
                echo %RunningOnlyQA%
                echo %NG_DEPLOY_PASSWORD%
                echo %message%
                echo "Root project password: %secure:NG_DEPLOY_PASSWORD%"
                echo "Root project password: %NG_DEPLOY_PASSWORD%"
                echo "%secure:teamcity.password.{NG_DEPLOY_PASSWORD}%"
                echo "%secure:teamcity.password.NG_DEPLOY_PASSWORD%"
                echo "init pass: %secure:teamcity.password.NG_DEPLOY_PASSWORD%"
                
                echo %credentialsJSON:NG_DEPLOY_PASSWORD%
                
                RUNNING_ONLY_QA="%RunningOnlyQA%"
                
                echo "RUNNING_ONLY_QA is ${'$'}RUNNING_ONLY_QA"
                if [ "${'$'}RUNNING_ONLY_QA" = true ]; then
                  echo "RUNNING_ONLY_QA is true"
                else
                  echo "RUNNING_ONLY_QA is false"
                fi
                
                ls -la ./
                
                bash -x
                
                rm -rf ./pass.yml
                rm -rf ./vault_pass.yml
                rm -rf ./ci_vault.sh
                
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.A_DEPLOY_PASSWORD' value='%A_DEPLOY_PASSWORD%'"
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.A_VAULT_PASSWORD' value='%A_VAULT_PASSWORD%'"
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.A_ENV_SECURITY' value='%A_ENV_SECURITY%'"
                
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.env.A_DEPLOY_PASSWORD' value='%A_DEPLOY_PASSWORD%'"
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.env.A_VAULT_PASSWORD' value='%A_VAULT_PASSWORD%'"
                echo "##teamcity[setParameter name='dep.ReactivePay_Main.env.A_ENV_SECURITY' value='%A_ENV_SECURITY%'"
                
                A_DEPLOY_PASSWORD="%A_DEPLOY_PASSWORD%"
                A_VAULT_PASSWORD="%A_VAULT_PASSWORD%"
                A_ENV_SECURITY="%A_ENV_SECURITY%"
                
                A_DEPLOY_PASSWORD_DEC="%A_DEPLOY_PASSWORD%"
                A_VAULT_PASSWORD_DEC="%A_VAULT_PASSWORD%"
                A_ENV_SECURITY_DEC="%A_ENV_SECURITY%"
                
                echo "A_DEPLOY_PASSWORD_DEC: ${'$'}A_DEPLOY_PASSWORD_DEC"
                echo "A_DEPLOY_PASSWORD: ${'$'}A_DEPLOY_PASSWORD"
                
                echo "A_VAULT_PASSWORD_DEC: ${'$'}A_VAULT_PASSWORD_DEC"
                echo "A_VAULT_PASSWORD: ${'$'}A_VAULT_PASSWORD"
                echo "A_ENV_SECURITY: ${'$'}A_ENV_SECURITY"
                
                echo "%A_DEPLOY_PASSWORD%" >> ./pass.yml
                echo "%A_VAULT_PASSWORD%" >> ./vault_pass.yml
                echo "A_DEPLOY_PASSWORD=%A_DEPLOY_PASSWORD%" >> ./ci_vault.sh
                echo "A_VAULT_PASSWORD=%A_VAULT_PASSWORD%" >> ./ci_vault.sh
                echo "A_ENV_SECURITY=%A_ENV_SECURITY%" >> ./ci_vault.sh
                echo "%message%" >> ./message.yml
                echo "%secure:message%" >> ./super_message.yml
                echo "%secure:teamcity.password.NG_DEPLOY_PASSWORD%" >> ./NG_DEPLOY_PASSWORD.yml 
                
                chmod +x ./ci_vault.sh
                ls -la ./
            """.trimIndent()
        }
        step {
            name = "init"
            type = "ReactivePayEngine_BuildChain_1initPrepareCi"
            enabled = false
            param("A_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
            param("env.reverse.dep.env.ReactivePay_Main.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
            param("INIT_PASS", "zxx175d32bfa837dc7e")
            param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
            param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
            param("env.reverse.dep.env.ReactivePay_Main.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
            param("message", "zxx775d03cbe80d301b")
            param("A_VAULT_PASSWORD", "zxx175d32bfa837dc7e")
            param("NG_DEPLOY_PASSWORD", "zxx775d03cbe80d301b")
        }
        step {
            type = "ReactivePayEngine_BuildChain_InitNg"
            enabled = false
            param("INIT_PASS", "zxx175d32bfa837dc7e")
            param("message", "zxx175d32bfa837dc7e")
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
    }
})
