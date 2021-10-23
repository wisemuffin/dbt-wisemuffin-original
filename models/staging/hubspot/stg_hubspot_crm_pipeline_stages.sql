with source as (
  {{ filter_stitch_relation(relation=var('stg_hubspot_crm_stitch_pipeline_stages_table'),unique_column='pipelineid') }}

),
renamed as (
    select
      pipelineid as pipeline_id,
      stageid as pipeline_stage_id,
      label as pipeline_stage_label,
      displayorder as pipeline_stage_display_order,
      probability pipeline_stage_close_probability_pct,
      closedwon as pipeline_stage_closed_won
    from source
)
select * from renamed
