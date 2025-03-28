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
