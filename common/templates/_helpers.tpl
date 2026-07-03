{{/*
Fully-qualified service name: stagecraft-<chart-name>, unless nameOverride is set.
*/}}
{{- define "common.fullname" -}}
{{- $name := .Values.nameOverride | default .Chart.Name -}}
stagecraft-{{ $name }}
{{- end -}}

{{/*
Component name: fullname + an optional suffix (.Values.componentSuffix), so a
chart with more than one Deployment (e.g. stagecraft-worker's "worker" and
"consumer" processes) can give each a distinct identity while still sharing
one ServiceAccount (common.fullname, always unsuffixed).
*/}}
{{- define "common.componentName" -}}
{{ include "common.fullname" . }}{{ .Values.componentSuffix | default "" }}
{{- end -}}

{{/*
Standard labels applied to every resource.
*/}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "common.componentName" . }}
app.kubernetes.io/part-of: stagecraft
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{/*
Selector labels — must be stable across releases (no version/managed-by churn).
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.componentName" . }}
{{- end -}}
