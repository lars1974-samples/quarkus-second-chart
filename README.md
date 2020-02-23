# Labeling strategies for single vs multi deployment/image apps
This is written from the two articles 
https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
https://helm.sh/docs/topics/chart_best_practices/labels/

# Labels
| Label                        | Selector | Single image app           | multi image app                    |
|------------------------------|:--------:|----------------------------|------------------------------------|
| app.kubernetes.io/name       | X        | .Chart.name                | <deployment>                       | 
| app.kubernetes.io/instance   | X        | .Release.Name              | .Release.Name                      |
| app.kubernetes.io/version    | X        | .Chart.appVersion          | .Values.<deployment>.image.version |
| app.kubernetes.io/part-of    |          | N/A                        | .Chart.name                        | 
| app.kubernetes.io/managed-by |          | .Release.Service           | .Release.Service                   |
| app.kubernetes.io/chart      |          | .Chart.Name-.Chart.Version | .Chart.Name-.Chart.Version         |

# metadata.name
The name of the kubernetes object should be put together of:
``` 
 Single deployment:
 .Chart.name - app.kubernetes.io/instance

 Multi deployment:
 app.kubernetes.io/part-of - app.kubernetes.io/instance .Values.<deployment>.name - 
``` 
If part-of name is contained in the instance name then the redundancy is removed. That relevant in tools like ArgoCD where
its natural to name af release of e.g. "great-app" to be called great-app-test. That logic is by default
implemented in the _helpers.tpl

# Multi deployment example
lets say an application "great-app" consists of 3 deployments: frontend, backend, database

Values.yaml:
``` 
frontend:
    name: frontend
    image:
        repository: myregistry/great-app-frontent
        version: 1.0.3
    more...

backend:
    name: backend
    image:
        repository: myregistry/great-app-backend
        version: 3.0.1
    more...

database:
    name: database
    image:
        repository: postgres
        version: 9.6.7-alpine
    more...
``` 

Let's say we create a an instance "test4" by running `helm install test4 great-app` or `helm template test4 great-app` the labeling will be:
#### All kubernetes objects
* app.kubernetes.io/instance: test4 (.Release.Name)
* app.kubernetes.io/part-of: great-app (.Chart.name)
* app.kubernetes.io/managed-by: helm (.Release.Service)
#### All backend objects
* app.kubernetes.io/name: backend (.Values.frontend.name)
* app.kubernetes.io/version: 1.0.3 (.Values.backend.image.version) 
#### All frontend objects
* app.kubernetes.io/name: frontend (.Values.frontend.name)
* app.kubernetes.io/version: 3.0.1 (.Values.frontend.image.version) 
#### All database objects
* app.kubernetes.io/name: database (.Values.frontend.name)
* app.kubernetes.io/version: 9.6.7-alpine (.Values.database.image.version) 

# Rewrite _helpers.tpl to support multiple deployments:
Because of many repetitions in in the kubernetes objects its recommended to extract the labeling logic to the _helpers.tpl. That's also how its done by default when you use `helm create <chart-name>`.
You can rewrite that default to support multiple deployments like this: [_helpers.tpl](/quarkus-second/templates/_helpers.tpl) When that is done the functions can be called like this:
```
{{ include "quarkus-second.fullname" ( set . "Deployment" .Values.database ) }}
```
Where the deployment is added like an extra entry in the global dictionary.