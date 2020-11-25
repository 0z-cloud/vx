package ReactivePayEngine_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2018_2.failureConditions.BuildFailureOnText
import jetbrains.buildServer.configs.kotlin.v2018_2.failureConditions.failOnText

object ReactiveEngine_NginxFrontendDnsBackend : BuildType({
    name = "4: FRONT | Update nginx frontend & DNS backend"
    description = "ReactivePay_Main"

    artifactRules = ".local/* => ansible_docker_build_result.zip"
    maxRunningBuilds = 2

    params {
        param("ANSIBLE_COMMIT_SHA", "%system.build.vcs.number%")
        param("ANSIBLE_VERSION", "")
        param("A_DEPLOY_PASSWORD", "")
        param("ANSIBLE_REGISTRY_USERNAME", "")
        param("ANSIBLE_CI_PROJECT_NAME", "")
        text("ANSIBLE_TRIGGER_TOKEN", "", allowEmpty = true)
        param("ANSIBLE_REGISTRY_URL", "")
        param("ANSIBLE_RUN_TYPE", "")
        text("ANSIBLE_DEPLOY_VAULT_PASSWORD", "", allowEmpty = true)
        param("A_VAULT_PASSWORD", "")
        param("ANSIBLE_CI_VERSION", "")
        param("ANSIBLE_DEPLOY_USERNAME", "")
        param("MAIN_ANSIBLE_BUILD_ID", "%env.BUILD_NUMBER%")
        param("ANSIBLE_ENVIRONMENT", "")
        param("ANSIBLE_CLOUD_TYPE", "")
        param("ANSIBLE_CI_PROJECT_NAMESPACE", "")
        param("ANSIBLE_PRODUCT_NAME", "")
        param("RunningOnlyQA", "")
        param("ANSIBLE_APPLICATION_TYPE", "")
    }

    vcs {
        root(DslContext.settingsRoot)
    }

    steps {
        script {
            name = "Update nginx frontend & DNS backend"
            scriptContent = """
                . ./ci_version.sh
                rm -rf ./ci_version.yml
                
                echo "MAIN_ANSIBLE_BUILD_ID: %MAIN_ANSIBLE_BUILD_ID%"
                echo "ANSIBLE_COMMIT_SHA: %ANSIBLE_COMMIT_SHA%"
                
                ANSIBLE_COMMIT_SHA_SHORT=`echo %ANSIBLE_COMMIT_SHA% | head -c 8`
                DATE_YEAR=`date '+%Y'`
                DATE_MOUTH=`date '+%m'`
                ANSIBLE_CI_VERSION="${'$'}{DATE_YEAR}.${'$'}{DATE_MOUTH}.%MAIN_ANSIBLE_BUILD_ID%-${'$'}{ANSIBLE_COMMIT_SHA_SHORT}"
                
                echo "ANSIBLE_CI_VERSION: ${'$'}ANSIBLE_CI_VERSION" >> ./ci_version.yml
                
                echo "Creating the temp shell settings file for pass values to next step"
                ls -la ../
                ls -la ./
                
                rm -rf ./ci_settings.sh
                rm -rf ./ci_version.yml
                
                #. ./ci_vault.sh
                
                echo "..............................."
                ls -la 
                echo "..............................."
                cd ./ansible
                echo "..............................."
                
                echo "pass %A_DEPLOY_PASSWORD%"
                echo "user %ANSIBLE_DEPLOY_USERNAME%"
                
                echo "hostname:"
                hostname
                
                echo "pip list:"
                pip list | egrep 'docker|docker-py|requests'
                
                echo %RunningOnlyQA%
                
                RUNNING_ONLY_QA="%RunningOnlyQA%"
                
                echo "RUNNING_ONLY_QA is ${'$'}RUNNING_ONLY_QA"
                
                if [ "${'$'}RUNNING_ONLY_QA" = true ]; then
                
                  echo "RUNNING_ONLY_QA is true"
                
                else
                
                    echo "RUNNING_ONLY_QA is false"
                
                    ./!_all_services_internal.sh "%ANSIBLE_ENVIRONMENT%" "%ANSIBLE_PRODUCT_NAME%" "%ANSIBLE_DEPLOY_USERNAME%" "%A_DEPLOY_PASSWORD%" "%ANSIBLE_APPLICATION_TYPE%" "%ANSIBLE_RUN_TYPE%" "%ANSIBLE_CLOUD_TYPE%" "%A_VAULT_PASSWORD%" "%ANSIBLE_REGISTRY_URL%" "%ANSIBLE_CI_PROJECT_NAME%" "%ANSIBLE_CI_PROJECT_NAMESPACE%" "${'$'}ANSIBLE_CI_VERSION" "${'$'}A_ENV_SECURITY"
                
                fi
                
                echo "..............................."
            """.trimIndent()
        }
    }

    failureConditions {
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "fatal:"
            failureMessage = "Stop on: fatal"
            reverse = false
            stopBuildOnFailure = true
        }
    }

    dependencies {
        dependency(ReactivePayEngine_BuildChain_PrepareCi) {
            snapshot {
                onDependencyFailure = FailureAction.FAIL_TO_START
            }

            artifacts {
                artifactRules = "ansible_prepare_result.zip!** => "
            }
        }
        snapshot(ReactivePayEngine_Infrastructure) {
            onDependencyFailure = FailureAction.FAIL_TO_START
        }
        dependency(ReactivePay_Main) {
            snapshot {
                onDependencyFailure = FailureAction.FAIL_TO_START
            }

            artifacts {
                artifactRules = "ansible_docker_build_result.zip!** => "
            }
        }
    }
})
