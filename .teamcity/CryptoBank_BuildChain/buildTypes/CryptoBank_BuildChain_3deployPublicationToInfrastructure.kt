package CryptoBank_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2018_2.failureConditions.BuildFailureOnText
import jetbrains.buildServer.configs.kotlin.v2018_2.failureConditions.failOnText

object CryptoBank_BuildChain_3deployPublicationToInfrastructure : BuildType({
    name = "3: DEPLOY | Publication to Infrastructure"

    allowExternalStatus = true
    enablePersonalBuilds = false
    artifactRules = "ansible_docker_build_result.zip!** => ./.local/"

    params {
        param("ANSIBLE_COMMIT_SHA", "")
        param("ANSIBLE_VERSION", "")
        param("ANSIBLE_REGISTRY_USERNAME", "")
        param("ANSIBLE_CI_PROJECT_NAME", "")
        text("ANSIBLE_TRIGGER_TOKEN", "", allowEmpty = true)
        param("ANSIBLE_REGISTRY_URL", "")
        param("ANSIBLE_RUN_TYPE", "")
        param("ANSIBLE_DEPLOY_USERNAME", "")
        param("ANSIBLE_ENVIRONMENT", "")
        param("env.ANSIBLE_ENVIRONMENT", "%ANSIBLE_ENVIRONMENT%")
        param("RunningOfferForPublish", "")
        param("ANSIBLE_CLOUD_TYPE", "")
        param("ANSIBLE_BUILD_ID", "")
        param("ANSIBLE_CI_PROJECT_NAMESPACE", "")
        param("ANSIBLE_PRODUCT_NAME", "")
        param("RunningOnlyQA", "")
        param("ANSIBLE_APPLICATION_TYPE", "")
    }

    vcs {
        root(DslContext.settingsRoot)

        cleanCheckout = true
        showDependenciesChanges = true
    }

    steps {
        script {
            name = "Publication to Infrastructure"
            scriptContent = """
                ls -la ./
                
                . ./ci_version.sh
                
                mkdir ./.local/
                
                mv ./current_tags.yml ./.local/
                mv ./ci_version.yml ./.local/
                mv ./ci_version.sh ./.local/
                mv ./ci_vault.sh ./.local/
                mv ./id_rsa ./.local/
                mv ./id_rsa.pub ./.local/
                mv ./pass.yml ./.local/
                mv ./vault-password-file-tmp.yml ./.local/
                mv ./vault-password-file.yml ./.local/
                mv ./vault_pass.yml ./.local/
                
                cat ./.local/current_tags.yml
                
                echo "Docker Login:"
                
                docker login "%ANSIBLE_REGISTRY_URL%" -u "%ANSIBLE_REGISTRY_USERNAME%" -p "%ANSIBLE_TRIGGER_TOKEN%"
                
                echo "Docker login complete"
                
                echo "Change dir to ansible"
                cd ./ansible
                echo "Show contents of parent .local folder"
                ls -la ../.local
                
                A_DEPLOY_PASSWORD=`cat ../.local/pass.yml`
                A_VAULT_PASSWORD=`cat ../.local/vault_pass.yml`
                
                RUNNING_ONLY_QA="%RunningOnlyQA%"
                
                echo "RUNNING_ONLY_QA is ${'$'}RUNNING_ONLY_QA"
                
                if [ "${'$'}RUNNING_ONLY_QA" = true ]; then
                
                  echo "RUNNING_ONLY_QA is true"
                
                else
                
                    echo "RUNNING_ONLY_QA is false"
                
                    RUNNING_DISABLE_PUBLISH="%RunningOfferForPublish%"
                
                    echo "RUNNING_DISABLE_PUBLISH is ${'$'}RUNNING_DISABLE_PUBLISH"
                
                    if [ "${'$'}RUNNING_DISABLE_PUBLISH" = true ]; then
                    
                      echo "RUNNING_DISABLE_PUBLISH is true"
                
                    else
                    
                      echo "RUNNING_DISABLE_PUBLISH is false"
                      
                      # echo "DEBUG:"
                      # echo "ANSIBLE_DEPLOY_USERNAME: ${'$'}ANSIBLE_DEPLOY_USERNAME"
                      # echo "A_DEPLOY_PASSWORD: ${'$'}A_DEPLOY_PASSWORD"
                
                      ./!_all_services_deployer.sh "${'$'}ANSIBLE_ENVIRONMENT" "${'$'}ANSIBLE_PRODUCT_NAME" "${'$'}ANSIBLE_DEPLOY_USERNAME" "${'$'}A_DEPLOY_PASSWORD" "${'$'}ANSIBLE_APPLICATION_TYPE" "${'$'}ANSIBLE_RUN_TYPE" "${'$'}ANSIBLE_CLOUD_TYPE" "${'$'}A_VAULT_PASSWORD" "${'$'}ANSIBLE_REGISTRY_URL" "${'$'}ANSIBLE_CI_PROJECT_NAME" "${'$'}ANSIBLE_CI_PROJECT_NAMESPACE" "${'$'}ANSIBLE_CI_VERSION" "${'$'}A_ENV_SECURITY"
                
                    fi
                
                fi
            """.trimIndent()
        }
    }

    failureConditions {
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "Connection to vpc.aliyuncs.com timed out"
            failureMessage = "Connection to vpc.aliyuncs.com timed out"
            reverse = false
            stopBuildOnFailure = true
        }
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "Failed to describe VPCs:"
            failureMessage = "Failed to describe VPCs"
            reverse = false
            stopBuildOnFailure = true
        }
    }

    dependencies {
        dependency(CryptoBank_BuildChain_2buildBuildAndPushDockerImages) {
            snapshot {
                onDependencyFailure = FailureAction.FAIL_TO_START
            }

            artifacts {
                artifactRules = "ansible_docker_build_result.zip!** => ./ "
            }
        }
    }
    
    disableSettings("BUILD_EXT_3")
})
