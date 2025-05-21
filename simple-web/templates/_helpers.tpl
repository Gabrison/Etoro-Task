
{{- define "simple-web.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "simple-web.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "simple-web.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "simple-web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple-web.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
