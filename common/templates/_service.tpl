{{/*
A ClusterIP Service — in-cluster only. External exposure is via an Ingress
(AWS Load Balancer Controller), not a Service type: LoadBalancer, so
stagecraft-frontend/stagecraft-api/stagecraft-webhook share one ALB.
*/}}
{{- define "common.service" -}}
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: ClusterIP
  selector:
    {{- include "common.selectorLabels" . | nindent 4 }}
  ports:
    - name: http
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
{{- end }}
{{- end -}}
