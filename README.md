# verifying-redhat-images

Examples of how to verify Red Hat images from [https://catalog.redhat.com](https://catalog.redhat.com/search?searchType=containers&partnerName=Red%20Hat&p=1)

## Cosign
`cosign` can be used to verify image signatures, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L20-L27)

## Podman
`podman` can be configured via its [policy.json](samples/HOME/.config/containers/policy-ubi9.json) and [registries.yaml](samples/HOME/.config/containers/registries.d/sigstore-registries.yaml)
to only allow signed images, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L40-L68)

## Skopeo

Since `skopeo` uses the same core [libraries](https://github.com/containers) as podman (_and buildah for that matter_),
we can use the same [policy.json](samples/HOME/.config/containers/policy-ubi9.json) and [registries.yaml](samples/HOME/.config/containers/registries.d/sigstore-registries.yaml)
to only allow signed images to be copied from one registry to another, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L40-L68)

## OCP 4.18 - ClusterImagePolicy

For OCP 4.18, a new feature called ImagePolicy is [Tech Preview](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/nodes/index#nodes-sigstore-configure-parameters_nodes-sigstore-using).
As its TP, a feature gate needs to be enabled which *STOPS* future cluster upgrades, so only do this on a sandbox cluster.

```bash
oc apply -f samples/ocp/FeatureGates.yaml
oc get ClusterImagePolicy/openshift -o yaml
```

Now the core OCP components images are validated against the Red Hat public key.

## OCP 4.18 - ImagePolicy

If you want to validate your own images, see [garethahealy_fulcio.yaml](samples/ocp/ImagePolicy/garethahealy_fulcio.yaml) as an example.

Firstly, we need to collect the public certs we need to validate with:

```bash
cosign initialize

export FULCIO_CA=$(awk '{print $0}' ~/.sigstore/root/targets/fulcio*.pem | base64 -w 0)
export REKOR_KEY=$(cat ~/.sigstore/root/targets/rekor.pub | base64 -w 0)

yq --inplace '.spec.policy.rootOfTrust.fulcioCAWithRekor.fulcioCAData = env(FULCIO_CA), .spec.policy.rootOfTrust.fulcioCAWithRekor.rekorKeyData = env(REKOR_KEY)' samples/ocp/ImagePolicy/quay_garethahealy_fulcio.yaml
```

Now, lets create the OCP bits:

```bash
oc create -f samples/ocp/Project.yaml
oc project playground

oc apply -f samples/ocp/ImagePolicy/garethahealy_fulcio.yaml
oc apply -f samples/ocp/Deployments/garethahealy.yaml

oc get pods
```

Hopefully, you should have a running pod - doing not much, as its just sleeping.

To validate the ImagePolicy is working correctly, lets patch the Deployment with an unsigned image:

```bash
oc patch deployment garethahealy --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":"quay.io/garethahealy/verifying-redhat-images:unsigned"}]'
```

Now looking at the running pods, we should see the signed (working correctly) and the unsigned pod showing a `SignatureValidationFailed` status:

```bash
oc get pods

NAME                            READY   STATUS                      RESTARTS   AGE
garethahealy-57f595d65d-wf69n   1/1     Running                     0          7m24s
garethahealy-5b99f5f8cb-92lbs   0/1     SignatureValidationFailed   0          12s
```
