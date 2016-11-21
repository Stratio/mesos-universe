@Library('libpipelines@feature/multibranch') _

hose {
    EMAIL = 'qa'
    MODULE = 'paasmu'
    REPOSITORY = 'mesos-universe'
    SLACKTEAM = 'stratiopaas'
    BUILDTOOL = 'make'
    DEVTIMEOUT = 30
    AGENT = 'DCOS'

    DEV = { config ->        
        doCompile(config)
        doPackage(conf: config, skipOnPR: true)
        doDeploy(config)
     }
}
