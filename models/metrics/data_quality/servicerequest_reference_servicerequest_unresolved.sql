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
      "description": "Proportion of ServiceRequest resources that reference a non-existent service request",
      "short_description": "SerReq ref. SerReq - non-exist",
      "primary_resource": "ServiceRequest",
      "primary_fields": ['requester.practitionerId'],
      "secondary_resources": [],
      "calculation": "PROPORTION",
      "category": "Referential integrity",
      "metric_date_field": "ServiceRequest.authoredOn",
      "metric_date_description": "Service request signed date",
      "dimension_a": "status",
      "dimension_a_description": "The status of the service request (draft | active | on-hold | revoked | completed | entered-in-error | unknown)",
      "dimension_b": "category",
      "dimension_b_description": "The category of the service request",
    }
) -}}

-- depends_on: {{ ref('ServiceRequest') }}

{%- set metric_sql -%}
    SELECT
      id,
      {{- metric_common_dimensions() }}
      status,
      {{ fhir_dbt_utils.code_from_codeableconcept(
        'category',
        'http://snomed.info/sct',
        return_field='display'
      ) }} AS category,
      {{ has_reference_value('basedOn', 'ServiceRequest') }} AS has_reference_value,
      {{ reference_resolves('basedOn', 'ServiceRequest') }} AS reference_resolves
    FROM {{ ref('ServiceRequest') }} AS S
{%- endset -%}

{{ calculate_metric(
    metric_sql,
    numerator = 'SUM(has_reference_value - reference_resolves)',
    denominator = 'COUNT(id)'
) }}
