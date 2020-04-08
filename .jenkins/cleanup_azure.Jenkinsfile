import hudson.slaves.*
import hudson.model.*

@Library("OpenEnclaveCommon") _
oe = new jenkins.common.Openenclave()

GLOBAL_TIMEOUT_MINUTES = 30

node("nonSGX") {
    stage("Cleanup Azure Deployments") {
        timeout(GLOBAL_TIMEOUT_MINUTES) {
            oe.azureEnvironment("""
                resourceGroup='your-resource-group'; \
                az group deployment list --resource-group $RESOURCE_GROUP --query "[*].name | [100:] | join(' ', @)" \
                | sed 's|[",]||g' \
                | xargs -n 1 -r \
                az group deployment delete --resource-group $RESOURCE_GROUP --name
            """)
        }
    }
}
