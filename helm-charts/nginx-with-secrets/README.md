# Nginx with Secrets Helm Chart

This Helm chart deploys Nginx with the ability to mount secret files from Kubernetes secrets.

## Introduction

This chart provisions a Nginx deployment with support for mounting secret files at specific paths inside the container.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installation

```bash
# From the helm-charts directory
helm install my-nginx-release ./nginx-with-secrets
```

## Configuration

The following table lists the configurable parameters of the nginx-with-secrets chart and their default values.

| Parameter                      | Description                                    | Default                         |
|--------------------------------|------------------------------------------------|---------------------------------|
| `replicaCount`                 | Number of replicas                             | `1`                             |
| `image.repository`             | Nginx image repository                         | `nginx`                         |
| `image.pullPolicy`             | Image pull policy                              | `IfNotPresent`                  |
| `image.tag`                    | Nginx image tag                                | `1.21.0`                        |
| `service.type`                 | Service type                                   | `ClusterIP`                     |
| `service.port`                 | Service port                                   | `80`                            |
| `secrets.fileSecret.enabled`   | Enable secret file mounting                    | `true`                          |
| `secrets.fileSecret.secretName`| Name of the secret to be created               | `nginx-file-secret`             |
| `secrets.fileSecret.volumeMountPath` | Path to mount the secret in the container | `/opt/harness/cluster-secret`  |
| `secrets.fileSecret.keys`      | List of key/path mappings for the secret       | See values.yaml                 |
| `secretData`                   | Actual secret data to be stored (encoded)      | See values.yaml                 |

## Secret Configuration

The chart creates a Kubernetes Secret based on the values provided in the `secretData` section of values.yaml. The keys in this section should match the keys defined in `secrets.fileSecret.keys`.

Example configuration:

```yaml
secrets:
  fileSecret:
    enabled: true
    secretName: nginx-file-secret
    volumeMountPath: "/opt/harness/cluster-secret"
    keys:
      - key: "PROD1_SECRET"
        path: "prod1.json"
      # Add more key/path mappings as needed
      # - key: "PROD2_SECRET"
      #   path: "prod2.json"

secretData:
  PROD1_SECRET: '{"key": "value"}'
  # PROD2_SECRET: '{"another": "secret"}'
```

## Security Note

In production environments, it's recommended to use external secret management tools such as HashiCorp Vault or Kubernetes external secrets rather than storing secret values directly in values files.
