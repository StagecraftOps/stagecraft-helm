{{/*
A ServiceAccount, annotated with an IRSA role ARN when serviceAccount.roleArn
is set (stagecraft-mcp has no AWS IAM needs, so it omits the annotation).

Hooked at a lower weight than api's migration Job (see migration-job.yaml)
so it's guaranteed to exist before that hook runs, on both fresh installs
and upgrades — a plain (non-hook) resource wouldn't exist yet during a
pre-install hook, since hooks run before any other template in the release.
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
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": before-hook-creation
    {{- if .Values.serviceAccount.roleArn }}
    eks.amazonaws.com/role-arn: {{ .Values.serviceAccount.roleArn }}
    {{- end }}
{{- end }}
{{- end -}}
