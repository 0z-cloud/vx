package ReactivePayEngine_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.buildFeatures.commitStatusPublisher
import jetbrains.buildServer.configs.kotlin.v2018_2.buildFeatures.pullRequests
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.script

object ReactivePayEngine_BuildChain_PythonQA : BuildType({
    templates(_Self.buildTypes.AnsibleDeployTemplate)
    name = "5: QA | Running test suite from PythonQA"
    description = "QA Section"

    artifactRules = "ansible_docker_build_result.zip!** => ./.local/"
    maxRunningBuilds = 0

    steps {
        script {
            name = "Run QA tests"
            id = "RUNNER_1"
            scriptContent = """
                echo "Show running dir contents"
                
                ls -la ./
                
                echo "Load the current tags"
                
                cat ./.local/current_tags.yml
                
                echo "Load the current version"
                
                . ./.local/ci_version.sh
                
                echo "Docker Login:"
                
                docker login "%ANSIBLE_REGISTRY_URL%" -u "%ANSIBLE_REGISTRY_USERNAME%" -p "%ANSIBLE_TRIGGER_TOKEN%"
                
                echo "Test env"
                cd ./ansible/group_vars/!_Python_QA
                python3 decrypt.py wiretest
                
                echo "Change dir to ansible"
                cd ../../
                
                echo "Show the current .local folder"
                
                ls -la ../.local
                
                echo "Show the password and vault password"
                
                #A_DEPLOY_PASSWORD=`cat ../.local/pass.yml`
                #A_VAULT_PASSWORD=`cat ../.local/vault_pass.yml`
                
                . ../.local/ci_vault.sh
                
                echo "Start run QA section, perform generate settings"
                
                ./!_0z-quality_assurance.sh "${'$'}ANSIBLE_ENVIRONMENT" "${'$'}ANSIBLE_PRODUCT_NAME" "${'$'}ANSIBLE_DEPLOY_USERNAME" "${'$'}A_DEPLOY_PASSWORD" "${'$'}ANSIBLE_APPLICATION_TYPE" "${'$'}ANSIBLE_RUN_TYPE" "${'$'}ANSIBLE_CLOUD_TYPE" "${'$'}A_VAULT_PASSWORD" "${'$'}ANSIBLE_REGISTRY_URL" "${'$'}ANSIBLE_CI_PROJECT_NAME" "${'$'}ANSIBLE_CI_PROJECT_NAMESPACE" "${'$'}ANSIBLE_CI_VERSION"
                
                echo "Change dir to PythonQA for run suite"
                
                ls -la ../PythonQA
                
                echo "Change dir to test suite folder"
                
                cd ../PythonQA
                
                echo "Install python requirements"
                
                pip3 install --no-cache-dir -r ./requirements.txt
                
                echo "Load the current QA settings per environment"
                
                . ./env.sh
                
                echo "Run QA test suite"
                echo "START"
                
                python3 decrypt.py wiretest
                
                session_id=${'$'}(python3 -s -m pytest metabase/session_test.py --runslow ${'$'}session_data --tb=long)
                
                echo ${'$'}session_id | sed -e 's/.*SessionID:\([0-9]\+\)*//g' | awk '{print ${'$'}1}' | sed -e 's/\|n//g' | sed -e "s/\\'//g" | sed -e "s/\\']//g"
                
                session_key=${'$'}(echo ${'$'}session_id | sed -e 's/.*SessionID:\([0-9]\+\)*//g' | awk '{print ${'$'}1}' | sed -e 's/\|n//g' | sed -e "s/\\']//g" | sed -e 's/\|//g' | sed -e "s/\\|']//g" | sed -e "s/\|//g" )
                
                session_token_result=${'$'}(echo ${'$'}session_key |  cut -f1 -d "|")
                echo "session_token_result: ${'$'}session_token_result"
                
                python3 -m pytest -p no:cacheprovider --direction %ANSIBLE_ENVIRONMENT% --session ${'$'}session_token_result
                
                echo "End"
            """.trimIndent()
        }
    }

    features {
        pullRequests {
            id = "BUILD_EXT_8"
            vcsRootExtId = "Teamctity"
            provider = gitlab {
                authType = token {
                    token = "zxxf970c21f550aba4ef2cfdb6afc1a75394dc767fdcf76cdec"
                }
            }
        }
        commitStatusPublisher {
            id = "BUILD_EXT_9"
            vcsRootExtId = "${DslContext.settingsRoot.id}"
            publisher = gitlab {
                gitlabApiUrl = "https://gitlab.adam.local.cloud.eve.vortice.eden/api/v4"
                accessToken = "zxxf970c21f550aba4ef2cfdb6afc1a75394dc767fdcf76cdec"
            }
        }
    }

    dependencies {
        snapshot(ReactiveEngine_NginxFrontendDnsBackend) {
            reuseBuilds = ReuseBuilds.NO
            onDependencyFailure = FailureAction.FAIL_TO_START
        }
        artifacts(ReactivePay_Main) {
            id = "ARTIFACT_DEPENDENCY_1"
            artifactRules = "ansible_docker_build_result.zip!** => ./.local/"
        }
    }
})
