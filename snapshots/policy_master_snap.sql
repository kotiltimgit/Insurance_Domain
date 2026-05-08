{% snapshot policy_master_snap %}

{{
    config(
        schema='INSURANCE_GOLD_DW',
        alias='POLICY_MASTER',
        unique_key='POLICY_ID',
        strategy='timestamp',
        updated_at='UPDATED_TS',
        invalidate_hard_deletes=True,
        tags=['gold_dw','type2','policy']
    )
}}

SELECT
    POLICY_ID,
    CUSTOMER_ID,
    POLICY_NUMBER,
    POLICY_TYPE,
    POLICY_STATUS,

    PREMIUM_AMOUNT,
    COVERAGE_AMOUNT,

    POLICY_START_DATE,
    POLICY_END_DATE,

    SOURCE_SYSTEM,
    SOURCE_UPDATED_TS,
    INGESTION_TS,

    IS_DELETED,

    UPDATED_TS,

    CURRENT_TIMESTAMP() AS DW_CREATED_TS

FROM {{ source('insurance_silver', 'POLICY') }}

WHERE IS_CURRENT = 'Y'

{% endsnapshot %}