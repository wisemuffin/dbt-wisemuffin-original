with source as (
  {{ filter_stitch_relation(relation=var('stg_hubspot_crm_stitch_deals_table'),unique_column='dealid') }}

),
hubspot_deal_pipelines_source as (
  SELECT *
  FROM
  {{ ref('stg_hubspot_crm_pipelines') }}
)
,
hubspot_deal_stages as (
  select *
  from  {{ ref('stg_hubspot_crm_pipeline_stages') }}
),
hubspot_deal_owners as (
  SELECT *
  FROM {{ ref('stg_hubspot_crm_owners') }}
),
renamed as (
  SELECT
        concat('{{ var('stg_hubspot_crm_id-prefix') }}',dealid) as deal_id,
        concat('{{ var('stg_hubspot_crm_id-prefix') }}',associatedcompanyids) as company_id,
        property_dealname                                     as deal_name,
        case when property_dealtype = 'newbusiness' then 'New Business'
             when property_dealtype = 'existingbusiness' then 'Existing Client'
             else 'Existing Client' end as deal_type,
        property_description                                  as deal_description,
        property_createdate                                   as deal_created_ts,
        property_delivery_schedule_date as delivery_schedule_ts,
        property_delivery_start_date as delivery_start_date_ts,
        property_closedate                                    as deal_closed_ts,
        property_hs_lastmodifieddate                          as deal_last_modified_ts,
        property_dealstage                                    as deal_pipeline_stage_id,
        property_dealstage                                as deal_pipeline_stage_ts,
        property_end_date         as deal_end_ts,
        property_hs_sales_email_last_replied                  as deal_sales_email_last_replied,
        property_engagements_last_meeting_booked              as deal_last_meeting_booked_date,
        property_hs_deal_stage_probability                    as deal_stage_probability_pct,
        property_pipeline                                     as deal_pipeline_id,
        property_hubspot_team_id                              as hubspot_team_id,
        property_hubspot_owner_id                             as deal_owner_id,
        property_hs_created_by_user_id                        as created_by_user_id,
        cast (null as boolean)                                      as deal_is_deleted,
        property_deal_currency_code                           as deal_currency_code,
        property_source                                       as deal_source,
        property_hs_analytics_source                          as hs_analytics_source,
        property_hs_analytics_source_data_1                   as hs_analytics_source_data_1,
        property_hs_analytics_source_data_2                   as hs_analytics_source_data_2,
        property_amount                                       as deal_amount,
        property_hs_projected_amount_in_home_currency         as projected_home_currency_amount,
        property_amount_in_home_currency                      as projected_local_currency_amount,
        property_hs_tcv                                       as deal_total_contract_amount,
        property_hs_acv                                       as deal_annual_contract_amount,
        property_hs_arr                                       as deal_annual_recurring_revenue_amount,
        property_hs_closed_amount                             as deal_closed_amount_value,
        property_hs_closed_amount_in_home_currency            as hs_closed_amount_in_home_currency,
        property_days_to_close                                as deal_days_to_close,
        property_closed_lost_reason                           as deal_closed_lost_reason,
        property_harvest_project_id                           as deal_harvest_project_id,
        property_number_of_sprints                            as deal_number_of_sprints,
        property_deal_components                              as deal_components,
        case when property_deal_components  like '%Services%' then true else false end as is_services_deal,
        case when property_deal_components  like '%Managed Services%' then true else false end as is_managed_services_deal,
        case when property_deal_components  like '%License Referral%' then true else false end as is_license_referral_deal,
        case when property_deal_components  like '%Training%' then true else false end as is_training_deal,
        case when property_deal_components  like '%Looker%' then true else false end as is_looker_skill_requirement,
        case when property_products_in_solution like '%Segment%' then true else false end as is_segment_skill_requirement,
        case when property_products_in_solution like '%dbt%' then true else false end as is_dbt_skill_requirement,
        case when property_products_in_solution like '%Stitch%' then true else false end as is_stitch_skill_requirement,
        case when property_products_in_solution like '%GCP%' then true else false end as is_gcp_skill_requirement,
        case when property_products_in_solution like '%Snowflake%' then true else false end as is_snowflake_skill_requirement,
        case when property_products_in_solution like '%Qubit%' then true else false end as is_qubit_skill_requirement,
        case when property_products_in_solution like '%Fivetran%' then true else false end as is_fivetran_skill_requirement,
        property_pricing_model                                as deal_pricing_model,
        property_partner_referral                             as deal_partner_referral,
        property_sprint_type                                  as deal_sprint_type,
        property_license_referral_harvest_project_code        as deal_license_referral_harvest_project_code,
        property_jira_project_code                            as deal_jira_project_code,
        property_assigned_consultant                          as deal_assigned_consultant,
        property_products_in_solution                         as deal_products_in_solution,
        property_hs_manual_forecast_category as manual_forecast_category,
        property_hs_forecast_probability as forecast_probability,
        property_hs_merged_object_ids as merged_object_ids,
        property_hs_predicted_amount as predicted_amount
      FROM
      source
),
joined as (
    select
    d.*,
    p.pipeline_label,
    p.pipeline_display_order,
    s.pipeline_stage_label,
    s.pipeline_stage_display_order,
    s.pipeline_stage_close_probability_pct,
    s.pipeline_stage_closed_won,
    u.owner_full_name,
    u.owner_email
    from renamed d
    join hubspot_deal_stages s on d.deal_pipeline_stage_id = s.pipeline_stage_id
    join hubspot_deal_pipelines_source p on s.pipeline_id = p.pipeline_id
    left outer join hubspot_deal_owners u on cast(d.deal_owner_id as int) = u.owner_id
)
select * from joined