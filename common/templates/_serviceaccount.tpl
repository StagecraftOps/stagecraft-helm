{{/*
A ServiceAccount, annotated with an IRSA role ARN when serviceAccount.roleArn
is set (stagecraft-mcp has no AWS IAM needs, so it omits the annotation).
*/}}
{{- define "common.serviceAccount" -}}
{{- if .Values.serviceAccount.create }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- if .Values.serviceAccount.roleArn }}
  annotations:
    eks.amazonaws.com/role-arn: {{ .Values.serviceAccount.roleArn }}
  {{- end }}
{{- end }}
{{- end -}}
