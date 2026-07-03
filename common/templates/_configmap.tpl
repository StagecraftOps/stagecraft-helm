{{/*
A ConfigMap holding this service's non-secret env vars (.Values.env). Secrets
(API keys, tokens) are expected to already exist as a Secret named
<fullname>-secrets, created out-of-band (e.g. via External Secrets / sealed-secrets)
— this chart never templates plaintext secrets into version control.
*/}}
{{- define "common.configMap" -}}
{{- if .Values.env }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullname" . }}-config
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.env }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end -}}
