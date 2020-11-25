package CryptoBank_BuildChain

import CryptoBank_BuildChain.buildTypes.*
import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.Project

object Project : Project({
    id("CryptoBank_BuildChain")
    name = "Build Chain"

    buildType(CryptoBank_BuildChain_4frontUpdateNginxFrontendDnsBackend)
    buildType(CryptoBank_BuildChain_PythonQA)
    buildType(CryptoBank_BuildChain_XSandboxPublishMoscowGit)
    buildType(CryptoBank_BuildChain_3deployPublicationToInfrastructure)
    buildType(CryptoBank_BuildChain_2buildBuildAndPushDockerImages)
    buildType(CryptoBank_BuildChain_PrepareCi)
    buildType(CryptoBank_BuildChain_PciOnePipeline)
})
