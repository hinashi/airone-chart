{{- define "airone.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 43 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "airone.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "airone.labels" -}}
helm.sh/chart: {{ include "airone.chart" . }}
{{ include "airone.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "airone.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Shared environment block used across each component.
*/}}
{{- define "airone.env" -}}
{{- if .Values.airone.sessionCookieSecure }}
- name: AIRONE_SESSION_COOKIE_SECURE
  value: {{ default  .Values.airone.sessionCookieSecure | quote }}
{{- end }}
{{- if not .Values.mysql.enabled }}
- name: AIRONE_MYSQL_URL
  {{- if .Values.externalMySQLSecret }}
  valueFrom:
    secretKeyRef:
      {{- .Values.externalMySQLSecret | toYaml | nindent 6 }}
  {{- else }}
  value: {{ default "" .Values.externalMySQL | quote }}
  {{- end }}
{{- else }}
- name: AIRONE_MYSQL_USER
  value: "{{ .Values.mysql.credentials.root.user }}"
- name: AIRONE_MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-cluster-secret
      key: rootPassword
- name: AIRONE_MYSQL_HOSTNAME
  value: "{{ .Release.Name }}-instances"
- name: AIRONE_MYSQL_DATABASE
  value: "{{ .Values.airone.database }}"
{{- end }}
{{- end -}}