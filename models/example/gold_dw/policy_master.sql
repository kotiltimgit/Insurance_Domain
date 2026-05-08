{{
    config(
        materialized='incremental',
        unique_key='POLICY_ID',
        schema='INSURANCE_SILVER',
        alias='POLICY_MASTER_TYPE1'
    )
}}

SELECT * FROM {{ source('insurance_silver', 'POLICY') }}
