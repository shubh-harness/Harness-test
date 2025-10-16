{{/*
Expand the name of the chart.
*/}}
{{- define "my-nginx-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "my-nginx-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-nginx-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-nginx-chart.labels" -}}
helm.sh/chart: {{ include "my-nginx-chart.chart" . }}
{{ include "my-nginx-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-nginx-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-nginx-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
========== INTELLIGENT VALUE MERGING HELPERS ==========
*/}}

{{/*
Get merged secrets from all override levels
Usage: {{ include "helpers.getAllSecrets" . }}
*/}}
{{- define "helpers.getAllSecrets" -}}
{{- $allSecrets := dict -}}

{{/* Merge from predefined levels in priority order */}}
{{- range $level := (list "base" "env1" "env2" "env3" "override" "custom") -}}
  {{- if hasKey $.Values $level -}}
    {{- $levelSecrets := index $.Values $level "secrets" | default dict -}}
    {{- range $key, $value := $levelSecrets -}}
      {{- $_ := set $allSecrets $key $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Also merge from direct .Values.secrets for backward compatibility */}}
{{- range $key, $value := ($.Values.secrets | default dict) -}}
  {{- $_ := set $allSecrets $key $value -}}
{{- end -}}

{{- $allSecrets | toYaml -}}
{{- end -}}

{{/*
Get merged config from all override levels
Usage: {{ include "helpers.getAllConfig" . }}
*/}}
{{- define "helpers.getAllConfig" -}}
{{- $allConfig := dict -}}

{{/* Merge from predefined levels in priority order */}}
{{- range $level := (list "base" "env1" "env2" "env3" "override" "custom") -}}
  {{- if hasKey $.Values $level -}}
    {{- $levelConfig := index $.Values $level "config" | default dict -}}
    {{- range $key, $value := $levelConfig -}}
      {{- $_ := set $allConfig $key $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Also merge from direct .Values.config for backward compatibility */}}
{{- range $key, $value := ($.Values.config | default dict) -}}
  {{- $_ := set $allConfig $key $value -}}
{{- end -}}

{{- $allConfig | toYaml -}}
{{- end -}}

{{/*
Generic merger for any path from multiple levels
Usage: {{ include "helpers.mergeFromLevels" (dict "root" . "path" "myData" "levels" (list "env1" "env2" "custom")) }}
*/}}
{{- define "helpers.mergeFromLevels" -}}
{{- $root := .root -}}
{{- $path := .path -}}
{{- $levels := .levels | default (list "base" "env1" "env2" "env3" "override" "custom") -}}
{{- $merged := dict -}}

{{- range $level := $levels -}}
  {{- if hasKey $root.Values $level -}}
    {{- $levelData := index $root.Values $level -}}
    {{- if hasKey $levelData $path -}}
      {{- $pathData := index $levelData $path -}}
      {{- range $key, $value := $pathData -}}
        {{- $_ := set $merged $key $value -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Also check direct values path for backward compatibility */}}
{{- if hasKey $root.Values $path -}}
  {{- $directData := index $root.Values $path -}}
  {{- range $key, $value := $directData -}}
    {{- $_ := set $merged $key $value -}}
  {{- end -}}
{{- end -}}

{{- $merged | toYaml -}}
{{- end -}}

{{/*
Smart merger with conflict resolution strategy
Usage: {{ include "helpers.smartMerge" (dict "root" . "path" "secrets" "strategy" "override" "levels" (list "base" "env1" "env2")) }}
Strategies: "override" (default), "append", "prefix"
*/}}
{{- define "helpers.smartMerge" -}}
{{- $root := .root -}}
{{- $path := .path -}}
{{- $strategy := .strategy | default "override" -}}
{{- $levels := .levels | default (list "base" "env1" "env2" "env3" "override" "custom") -}}
{{- $merged := dict -}}

{{- range $level := $levels -}}
  {{- if hasKey $root.Values $level -}}
    {{- $levelData := index $root.Values $level -}}
    {{- if hasKey $levelData $path -}}
      {{- $pathData := index $levelData $path -}}
      {{- range $key, $value := $pathData -}}
        {{- if eq $strategy "override" -}}
          {{- $_ := set $merged $key $value -}}
        {{- else if eq $strategy "append" -}}
          {{- if hasKey $merged $key -}}
            {{- $existing := index $merged $key -}}
            {{- $_ := set $merged $key (printf "%s,%s" $existing $value) -}}
          {{- else -}}
            {{- $_ := set $merged $key $value -}}
          {{- end -}}
        {{- else if eq $strategy "prefix" -}}
          {{- $prefixedKey := printf "%s_%s" $level $key -}}
          {{- $_ := set $merged $prefixedKey $value -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $merged | toYaml -}}
{{- end -}}
