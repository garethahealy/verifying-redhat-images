# verifying-redhat-images

Examples of how to verify Red Hat images from [https://catalog.redhat.com](https://catalog.redhat.com/search?searchType=containers&partnerName=Red%20Hat&p=1)

## Cosign
`cosign` can be used to verify image signatures, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L20-L27)

## Podman
`podman` can be configured via its [policy.json](samples/HOME/.config/containers/policy.json) and [registries.yaml](samples/HOME/.config/containers/registries.d/sigstore-registries.yaml)
to only allow signed images, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L40-L68)

## Skopeo

Since `skopeo` uses the same core [libraries](https://github.com/containers) as podman (_and buildah for that matter_),
we can use the same [policy.json](samples/HOME/.config/containers/policy.json) and [registries.yaml](samples/HOME/.config/containers/registries.d/sigstore-registries.yaml)
to only allow signed images to be copied from one registry to another, see: [.github/workflows/verify.yaml](https://github.com/garethahealy/verifying-redhat-images/blob/main/.github/workflows/verify.yaml#L40-L68)

## OCP 4.18 - ImagePolicy

For OCP 4.18, a new feature called ImagePolicy is [Tech Preview](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html-single/nodes/index#nodes-sigstore-configure-parameters_nodes-sigstore-using).
As its TP, a feature gate needs to be enabled which *STOPS* future cluster upgrades, so only do this on a sandbox cluster.

```bash
oc apply -f samples/ocp/FeatureGates.yaml
oc get ClusterImagePolicy/openshift -o yaml
```

Now the core OCP components images are validated against the Red Hat public key.

If you want to validate your own images, see [quay_podman_hello.yaml](samples/ocp/ClusterImagePolicys/quay_podman_hello.yaml) as an example.

```bash
oc apply -f samples/ocp/ClusterImagePolicys/quay_podman_hello.yaml
oc apply -f samples/ocp/Pods/hello.yaml

oc describe deployment/hello
oc get pods
oc get events
```

The pod should have a `ImagePullBackOff` status with an error of `Failed to pull image "quay.io/podman/hello:latest": SignatureValidationFailed: copying system image from manifest list: Source image rejected: A signature was required, but no signature exists`
