package CryptoBank_BuildChain.buildTypes

import jetbrains.buildServer.configs.kotlin.v2018_2.*

object CryptoBank_BuildChain_PciOnePipeline : BuildType({
    name = "PCI_One_pipeline"

    allowExternalStatus = true
    enablePersonalBuilds = false
    artifactRules = "ansible_build_result.zip!** => ./"
    maxRunningBuilds = 1

    params {
        param("ANSIBLE_COMMIT_SHA", "")
        param("ANSIBLE_VERSION", "")
        param("A_DEPLOY_PASSWORD", "")
        param("ANSIBLE_REGISTRY_USERNAME", "")
        param("ANSIBLE_CI_PROJECT_NAME", "")
        text("ANSIBLE_TRIGGER_TOKEN", "", allowEmpty = true)
        param("ANSIBLE_REGISTRY_URL", "")
        param("ANSIBLE_RUN_TYPE", "")
        param("A_VAULT_PASSWORD", "")
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
        step {
            name = "Prepare CI"
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
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "Front"
            type = "ReactivePayEngine_BuildChain_4frontUpdateNginxFrontendDnsBackend"
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
        step {
            name = "QA"
            type = "ReactivePayEngine_BuildChain_5qaRunningTestSuiteFromPythonQA"
            param("NG_DEPLOY_PASSWORD", "zxx175d32bfa837dc7e")
        }
    }

    dependencies {
        artifacts(CryptoBank_BuildChain_2buildBuildAndPushDockerImages) {
            artifactRules = "ansible_docker_build_result.zip!** => ./"
            enabled = false
        }
    }
})
