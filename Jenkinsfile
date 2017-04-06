@Library('libpipelines@master') _

hose {
    EMAIL = 'qa'
    MODULE = 'mesos-universe'
    REPOSITORY = 'github.com/mesos-universe'
    SLACKTEAM = 'stratiopaas'
    BUILDTOOL = 'make'
    DEVTIMEOUT = 30
    RELEASETIMEOUT = 120 

    DEV = { config ->        
        doCompile(config)
        doPackage(conf: config, skipOnPR: true)
        doDeploy(config)
     }
}
