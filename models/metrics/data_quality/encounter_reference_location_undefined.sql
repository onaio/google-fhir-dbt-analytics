{#
/* Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */
#}

{{ config(
    meta = {
      "description": "Proportion of Encounter resources that do not have a location reference recorded",
      "short_description": "Enc ref. Loc - unrecorded",
      "primary_resource": "Encounter",
      "primary_fields": ['location.location.locationId'],
      "secondary_resources": [],
      "calculation": "PROPORTION",
      "category": "Referential integrity",
      "metric_date_field": "Encounter.period.start",
      "metric_date_description": "Encounter start date",
      "dimension_a": "status",
      "dimension_a_description": "The status of the encounter (planned | arrived | triaged | in-progress | onleave | finished | cancelled +)",
      "dimension_b": "latest_encounter_class",
      "dimension_b_description": "The latest class of the encounter",
    }
) -}}

-- depends_on: {{ ref('Encounter') }}
{%- if fhir_resource_exists('Encounter') %}

WITH
  A AS (
    SELECT
      id,
      {{- metric_common_dimensions() }}
      status,
      class.code AS latest_encounter_class,
      (
        SELECT SIGN(COUNT(*))
        FROM UNNEST(E.location) AS EL
        WHERE EL.location.locationId IS NOT NULL
        AND EL.location.locationId <> ''
      ) AS has_reference_location
    FROM {{ ref('Encounter') }} AS E
  )
{{ calculate_metric(
    numerator = 'SUM(1 - has_reference_location)',
    denominator = 'COUNT(id)'
) }}

{%- else %}
{{- empty_metric_output() -}}
{%- endif -%}