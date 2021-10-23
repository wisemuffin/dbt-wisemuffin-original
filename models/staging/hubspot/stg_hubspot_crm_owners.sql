WITH source as (
  {{ filter_stitch_relation(relation=var('stg_hubspot_crm_stitch_owners_table'),unique_column='ownerid') }}

),
renamed as (
    select
      ownerid as owner_id,
      concat(concat(firstname,' '),lastname) as owner_full_name,
      firstname as owner_first_name,
      lastname as owner_last_name,
      email as owner_email
    from source
)
select * from renamed
