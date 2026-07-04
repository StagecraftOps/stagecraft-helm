{{/*
An ExternalSecret that pulls this service's JSON secret out of AWS Secrets
Manager (via the ClusterSecretStore the umbrella chart installs) and lays its
keys out flat as a Kubernetes Secret named <fullname>-secrets — exactly the
Secret common.deployment already wires up via envFrom.secretRef.
*/}}
{{- define "common.externalSecret" -}}
{{- if .Values.externalSecret.enabled }}
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: {{ include "common.fullname" . }}-secrets
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  secretStoreRef:
    name: {{ .Values.externalSecret.storeName }}
    kind: ClusterSecretStore
  target:
    name: {{ include "common.fullname" . }}-secrets
    creationPolicy: Owner
  refreshInterval: {{ .Values.externalSecret.refreshInterval | default "1h" }}
  dataFrom:
    - extract:
        key: {{ .Values.externalSecret.awsSecretName }}
{{- end }}
{{- end -}}
