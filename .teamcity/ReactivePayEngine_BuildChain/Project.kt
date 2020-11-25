package ReactivePayEngine_BuildChain

import ReactivePayEngine_BuildChain.buildTypes.*
import jetbrains.buildServer.configs.kotlin.v2018_2.*
import jetbrains.buildServer.configs.kotlin.v2018_2.Project

object Project : Project({
    id("ReactivePayEngine_BuildChain")
    name = "Build Chain"

    buildType(ReactivePay_Main)
    buildType(ReactivePayEngine_BuildChain_PrepareCi)
    buildType(ReactiveEngine_NginxFrontendDnsBackend)
    buildType(ReactivePayEngine_XSandboxPublishMoscowGit)
    buildType(ReactivePayEngine_Infrastructure)
    buildType(ReactivePayEngine_BuildChain_PythonQA)
    buildType(ReactivePayEngine_BuildChain_PciOnePipeline)
})
