@Library('libpipelines@master') _

hose {
    EMAIL = 'qa'
    MODULE = 'mesos-universe'
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
