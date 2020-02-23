{{/* vim: set filetype=mustache: */}}

{{/* Create a default fully qualified app name. If release name contains chart name it will be used as a full name. */}}
{{- define "quarkus-second.fullname" -}}
{{- $name := .Chart.Name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- printf "%s-%s-%s" .Release.Name $name .Deployment.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "quarkus-second.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels */}}
{{- define "quarkus-second.labels" -}}
helm.sh/chart: {{ include "quarkus-second.chart" . }}
{{ include "quarkus-second.selectorLabels" . }}
app.kubernetes.io/version: {{ .Deployment.image.version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels */}}
{{- define "quarkus-second.selectorLabels" -}}
app.kubernetes.io/name: {{ .Deployment.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}