package CryptoBank_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.buildFeatures.commitStatusPublisher
import jetbrains.buildServer.configs.kotlin.v2018_2.buildFeatures.pullRequests

object CryptoBank_BuildChain_XSandboxPublishMoscowGit : BuildType({
    name = "X. Sandbox-Publish ^ Moscow ^ Git"

    enablePersonalBuilds = false
    type = BuildTypeSettings.Type.DEPLOYMENT
    maxRunningBuilds = 1

    params {
        param("ANSIBLE_COMMIT_SHA", "%system.build.vcs.number%")
        param("A_DEPLOY_PASSWORD", "credentialsJSON:b2bc6c27-ec64-413a-b27c-8a32e5628dd9")
        param("ANSIBLE_REGISTRY_USERNAME", "root")
        param("ANSIBLE_CI_PROJECT_NAME", "wirecapital_gate")
        text("ANSIBLE_TRIGGER_TOKEN", "o5hqKNkto4-VPRP2xQh4", allowEmpty = true)
        param("main_build_id", "${CryptoBank_BuildChain_2buildBuildAndPushDockerImages.depParamRefs["build.counter"]}")
        checkbox("RunningOfferForBuild", "", label = "Disable run Build suite pipeline step", display = ParameterDisplay.PROMPT,
                  checked = "true", unchecked = "false")
        param("ANSIBLE_REGISTRY_URL", "registry.adam.local.cloud.eve.vortice.eden")
        param("TEST_VALUE", "TEST_VALUE")
        param("ANSIBLE_RUN_TYPE", "true")
        param("A_VAULT_PASSWORD", "credentialsJSON:b2bc6c27-ec64-413a-b27c-8a32e5628dd9")
        param("env.reverse.dep.*.env.A_MAIN_VERSION", "%env.A_MAIN_VERSION%")
        text("ANSIBLE_DEPLOY_USERNAME", "", label = "DEPLOY USERNAME", display = ParameterDisplay.PROMPT, allowEmpty = true)
        param("ANSIBLE_ENVIRONMENT", "sandbox")
        param("env.A_MAIN_VERSION", "%main_build_id%")
        param("BuildNumber", "%build.number%")
        checkbox("RunningOfferForPublish", "", label = "Disable run Publish suite pipeline step", display = ParameterDisplay.PROMPT,
                  checked = "true", unchecked = "false")
        param("ANSIBLE_CLOUD_TYPE", "bare")
        param("dep.ReactivePay_Main.build.counter", "")
        param("ANSIBLE_CI_PROJECT_NAMESPACE", "wirecapital")
        param("ANSIBLE_PRODUCT_NAME", "moscow-wire")
        param("A_ENV_SECURITY", "pci")
        checkbox("RunningOnlyQA", "", label = "Running only test suite", display = ParameterDisplay.PROMPT,
                  checked = "true", unchecked = "false")
        param("ANSIBLE_APPLICATION_TYPE", "rails")
    }

    vcs {
        root(DslContext.settingsRoot)

        showDependenciesChanges = true
    }

    steps {
        step {
            name = "Init"
            type = "ReactivePayEngine_BuildChain_1initPrepareCi"
            param("env.reverse.dep.env.ReactivePay_Main.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
            param("INIT_PASS", "zxx175d32bfa837dc7e")
            param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_DEPLOY_PASSWORD", "%A_DEPLOY_PASSWORD%")
            param("env.reverse.dep.env.ReactivePayEngine_Infrastructure.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
            param("env.reverse.dep.env.ReactivePay_Main.A_VAULT_PASSWORD", "%A_VAULT_PASSWORD%")
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "Build"
            type = "ReactivePayEngine_BuildChain_2buildBuildAndPushDockerImages"
            param("A_DEPLOY_PASSWORD", "")
            param("ANSIBLE_DEPLOY_VAULT_PASSWORD", "")
            param("A_VAULT_PASSWORD", "")
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "Deploy"
            type = "ReactivePayEngine_BuildChain_3deployPublicationToInfrastructure"
            enabled = false
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "Front"
            type = "ReactivePayEngine_BuildChain_4frontUpdateNginxFrontendDnsBackend"
            enabled = false
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "QA"
            type = "ReactivePayEngine_BuildChain_5qaRunningTestSuiteFromPythonQA"
            enabled = false
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
    }

    features {
        commitStatusPublisher {
            enabled = false
            vcsRootExtId = "${DslContext.settingsRoot.id}"
            publisher = gitlab {
                gitlabApiUrl = "https://gitlab.adam.local.cloud.eve.vortice.eden/api/v4"
                accessToken = "zxxf970c21f550aba4ef2cfdb6afc1a75394dc767fdcf76cdec"
            }
        }
        pullRequests {
            enabled = false
            vcsRootExtId = "Teamctity"
            provider = gitlab {
                authType = token {
                    token = "zxxf970c21f550aba4ef2cfdb6afc1a75394dc767fdcf76cdec"
                }
            }
        }
    }
})
