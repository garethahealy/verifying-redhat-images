#!/usr/bin/env zsh

#doitlive shell: /bin/zsh
#doitlive speed: 3
#doitlive commentecho: false

# First off, we need to be on OCP 4.20 for this feature to be supported
oc version

# Lets check ClusterImagePolicy and ImagePolicy CR exists
oc api-resources --api-group=config.openshift.io --sort-by=name | grep "ImagePolicy"

# In OCP 4.20, the cluster automatically deploying its own validation is still tech-preview
# So we need to deploy a FeatureGate
cat samples/ocp/FeatureGates.yaml
oc apply -f samples/ocp/FeatureGates.yaml

# Now, lets check default policy has been created
oc get ClusterImagePolicy/openshift

# And lets look at the content
oc get ClusterImagePolicy/openshift -o yaml

# Cool, but how do i verify the CR has updated the node config for CRIO? lets debug a node!
oc get nodes
oc debug node/$(oc get nodes --selector=node-role.kubernetes.io/worker -o json | jq -r '.items[0].metadata.name') -- chroot /host cat /etc/containers/policy.json

# And now lets apply a unsigned release payload
oc new-project playground
cat samples/ocp/Deployments/ocp-release.yaml
oc apply -f samples/ocp/Deployments/ocp-release.yaml

# Which will be rejected due to SignatureVerifcation
oc get pods --watch=true
