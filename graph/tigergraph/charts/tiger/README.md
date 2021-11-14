# TigerGraph
## Overview

TigerGraph is a super fast, transactional and easy to use distributed
graph database.

## Requirements
For installation requirements refer to the [TigerGraph documentation](https://docs.tigergraph.com/admin/admin-guide/hw-and-sw-requirements)

**Warning**: TigerGraph doesn't support downgrading from a higher version to a lower version.

## Installation

TigerGraph can be installed on a Kubernetes cluster in two ways:

- [Official method using Kustomize](https://docs.tigergraph.com/v/3.3/admin/admin-guide/kubernetes)
- Helm chart in this directory - **Unsupported**

THe Helm chart supports deployment into any specified namespace.  Specify number of TigerGraph server nodes using [values.yaml](./values.yaml) or `--set`

Example installation using Helm into default namespace using `values.yaml` for all parameters

```sh
helm install tigergraph .
```

Example installing into newly created namespace and overriding values with `--set``

```sh
helm install tigergraph --namespace tiger --create-namespace --set replicaCount=3,image.tag=3.3.0 .
```

# Documentation

The official TigerGraph documentation is [here.](https://docs.tigergraph.com)

# Community

Have a look at [TigerGraph Community Resources](https://www.tigergraph.com/community/)

There is a very active [Discord Server for Developers](https://discord.gg/F2c9b9v)
