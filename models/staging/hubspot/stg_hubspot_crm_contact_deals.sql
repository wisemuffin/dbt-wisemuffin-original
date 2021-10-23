{% if var("crm_warehouse_contact_sources") and var("marketing_warehouse_deal_sources")%}
{% if 'hubspot_crm' in var("crm_warehouse_contact_sources") and 'hubspot_crm' in var("marketing_warehouse_deal_sources") %}

with source as (
  {{ filter_stitch_relation(relation=var('stg_hubspot_crm_stitch_contact_deals_table'),unique_column='dealid') }}
),
renamed as (
SELECT
  concat('{{ var('stg_hubspot_crm_id-prefix') }}',dealid) as deal_id,
  concat('{{ var('stg_hubspot_crm_id-prefix') }}',associatedvids) as contact_id
FROM
  source
)
select *
from   renamed

{% else %} {{config(enabled=false)}} {% endif %}
{% else %} {{config(enabled=false)}} {% endif %}
