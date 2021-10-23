with source as (
  select *
  from {{var('stg_hubspot_crm_stitch_deal_pipelines_table')}}
),
renamed as (
    select
      label as pipeline_label,
      pipelineid as pipeline_id,
      displayorder as pipeline_display_order,
      active as pipeline_active
    from source
)
select * from renamed
