# Labeling strategies for single vs multi deployment/image apps
This is written from the two articles 
https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
https://helm.sh/docs/topics/chart_best_practices/labels/

# Labels
| Label | Selector | Single image app | multi image app | description |
|-------|:--------:|------------------|-----------------|-------------|
| app.kubernetes.io/name | X | .Chart.name | <component-name> | 
| app.kubernetes.io/instance | X | .Release.Name | .Release.Name | The first arg when helm template or helm install
| app.kubernetes.io/version | X | .Chart.appVersion | .Values.<component-name>.image.version |
| app.kubernetes.io/part-of | | N/A | .Chart.name | 
| app.kubernetes.io/managed-by | | .Release.Service |
| app.kubernetes.io/chart | | .Chart.Name-.Chart.Version | .Chart.Name-.Chart.Version

# metadata.name
The name of the kubernetes object should be put together of:
``` 
 single deployment:
 app.kubernetes.io/name - app.kubernetes.io/instance
 multi deployment:
 app.kubernetes.io/part-of - app.kubernetes.io/name - app.kubernetes.io/instance
``` 
Where the content of of the labels can be derived from the table above.

# Multi deployment example
lets say an application "great-app" consists of 3 deployments: frontend, backend, database

Values.yaml:
``` 
frontend:
    image:
        repository: myregistry/great-app-frontent
        version: 1.0.3
    more...

backend:
    image:
        repository: myregistry/great-app-backend
        version: 3.0.1
    more...

database:
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
* app.kubernetes.io/name: backend
* app.kubernetes.io/version: 1.0.3 (.Values.backend.image.version) 
#### All frontend objects
* app.kubernetes.io/name: frontend
* app.kubernetes.io/version: 3.0.1 (.Values.frontend.image.version) 
#### All database objects
* app.kubernetes.io/name: database 
* app.kubernetes.io/version: 9.6.7-alpine (.Values.database.image.version) 