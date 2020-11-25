package _Self.buildTypes

import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.failureConditions.BuildFailureOnText
import jetbrains.buildServer.configs.kotlin.v2019_2.failureConditions.failOnText

object AnsibleDeployTemplate : Template({
    name = "Ansible_Deploy_Template"
    description = "Ansible Deploy Template"

    allowExternalStatus = true
    enablePersonalBuilds = false
    artifactRules = "ansible_build_result.zip!** => ./"
    maxRunningBuilds = 1

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
        param("ANSIBLE_CLOUD_TYPE", "")
        param("ANSIBLE_BUILD_ID", "")
        param("ANSIBLE_CI_PROJECT_NAMESPACE", "")
        param("ANSIBLE_PRODUCT_NAME", "")
        param("ANSIBLE_APPLICATION_TYPE", "")
    }

    vcs {
        root(DslContext.settingsRoot)

        showDependenciesChanges = true
    }

    steps {
        script {
            name = "Build docker images"
            id = "RUNNER_1"
            scriptContent = """
                ls -la ./
                
                cat ./current_tags.yml
                
                echo "ANSIBLE_BUILD_ID: %ANSIBLE_BUILD_ID%"
                echo "ANSIBLE_COMMIT_SHA: %ANSIBLE_COMMIT_SHA%"
                
                ANSIBLE_COMMIT_SHA_SHORT=`echo %ANSIBLE_COMMIT_SHA% | head -c 8`
                
                DATE_YEAR=`date '+%Y'`
                DATE_MOUTH=`date '+%m'`
                ANSIBLE_CI_VERSION="${'$'}{DATE_YEAR}.${'$'}{DATE_MOUTH}.%ANSIBLE_BUILD_ID%-${'$'}{ANSIBLE_COMMIT_SHA_SHORT}"
                
                echo "ANSIBLE_COMMIT_SHA_SHORT: ${'$'}ANSIBLE_COMMIT_SHA_SHORT"
                echo "ANSIBLE_APPLICATION_TYPE: %ANSIBLE_APPLICATION_TYPE%"
                echo "ANSIBLE_CI_PROJECT_NAME: %ANSIBLE_CI_PROJECT_NAME%"
                echo "ANSIBLE_CI_PROJECT_NAMESPACEL: %ANSIBLE_CI_PROJECT_NAMESPACE%"
                echo "ANSIBLE_CLOUD_TYPE: %ANSIBLE_CLOUD_TYPE%"
                echo "ANSIBLE_DEPLOY_USERNAME: %ANSIBLE_DEPLOY_USERNAME%"
                echo "ANSIBLE_ENVIRONMENT: %ANSIBLE_ENVIRONMENT%"
                echo "ANSIBLE_PRODUCT_NAME: %ANSIBLE_PRODUCT_NAME%"
                echo "ANSIBLE_REGISTRY_URL: %ANSIBLE_REGISTRY_URL%"
                echo "ANSIBLE_REGISTRY_USERNAME: %ANSIBLE_REGISTRY_USERNAME%"
                echo "ANSIBLE_RUN_TYPE: %ANSIBLE_RUN_TYPE%"
                echo "ANSIBLE_TRIGGER_TOKEN: %ANSIBLE_TRIGGER_TOKEN%"
                echo "ANSIBLE_CI_VERSION: ${'$'}ANSIBLE_CI_VERSION"
                
                echo "Docker Login:"
                
                docker login "%ANSIBLE_REGISTRY_URL%" -u "%ANSIBLE_REGISTRY_USERNAME%" -p "%ANSIBLE_TRIGGER_TOKEN%"
                
                cd ./ansible
            """.trimIndent()
        }
    }

    failureConditions {
        failOnText {
            id = "BUILD_EXT_3"
            enabled = false
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "fatal:"
            failureMessage = "Stop on: fatal"
            reverse = false
        }
    }

    dependencies {
        dependency(RelativeId("BuildChain_2buildBuildAndPushDockerImages")) {
            snapshot {
                onDependencyFailure = FailureAction.FAIL_TO_START
            }

            artifacts {
                id = "ARTIFACT_DEPENDENCY_1"
                artifactRules = "ansible_docker_build_result.zip!** => ./"
            }
        }
    }
})
