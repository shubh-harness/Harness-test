# TodoList Helm Chart

A Helm chart for deploying a TodoList application with Custom Resource Definitions (CRDs).

## Features

- Deploys a Todo List application
- Installs Custom Resource Definitions (CRDs) for TodoList and TodoItem resources
- Creates a sample TodoList resource
- Provides persistence options for storing todo data

## Installation

There are two recommended ways to install this chart, depending on whether you want the CRDs to be managed by Helm:

### Option 1: Install CRDs separately first (Recommended for Production)

This approach installs the CRDs first and then the rest of the chart. This is the most reliable way to handle CRDs with Helm:

```bash
# Install CRDs first
kubectl apply -f helm-charts/todolist/crds/

# Then install the chart
helm install todolist helm-charts/todolist --set crds.install=false
```

### Option 2: Install everything together

This approach installs CRDs along with other resources:

```bash
helm install todolist helm-charts/todolist
```

## Configuration

The following table lists the configurable parameters of the TodoList chart and their default values.

| Parameter                | Description                           | Default     |
|--------------------------|---------------------------------------|-------------|
| `replicaCount`           | Number of replicas                    | `2`         |
| `image.repository`       | Image repository                      | `todolist`  |
| `image.tag`              | Image tag                             | `1.0.0`     |
| `image.pullPolicy`       | Image pull policy                     | `IfNotPresent` |
| `service.type`           | Service type                          | `ClusterIP` |
| `service.port`           | Service port                          | `80`        |
| `persistence.enabled`    | Enable persistence                    | `true`      |
| `persistence.size`       | PVC size                              | `1Gi`       |
| `crds.install`           | Whether to install CRDs               | `true`      |
| `crds.keep`              | Whether to keep CRDs after deletion   | `true`      |

## CRD Management

The TodoList Helm chart provides two CRDs:

1. `TodoList`: For managing todo lists
2. `TodoItem`: For managing individual todo items

The CRD installation is controlled by the `crds.install` and `crds.keep` values:

- `crds.install`: Set to `true` to install CRDs, `false` to skip
- `crds.keep`: Set to `true` to preserve CRDs on chart deletion, `false` to remove them

## Examples

### TodoList Resource Example

```yaml
apiVersion: todo.example.com/v1
kind: TodoList
metadata:
  name: my-todos
spec:
  title: My Todo List
  description: Things I need to do today
  items:
    - name: Buy groceries
      completed: false
      priority: high
    - name: Call mom
      completed: false
      priority: medium
```

### TodoItem Resource Example

```yaml
apiVersion: todo.example.com/v1
kind: TodoItem
metadata:
  name: call-dentist
spec:
  name: Call dentist
  description: Make an appointment for next week
  completed: false
  priority: high
  listRef:
    name: my-todos
    namespace: default
```

## Uninstalling the Chart

```bash
helm delete todolist
```

Note: If `crds.keep` is set to `true` (default), the CRDs will remain after the chart is deleted. To remove them:

```bash
kubectl delete crd todolists.todo.example.com todoitems.todo.example.com
```
