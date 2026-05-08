{% snapshot policy_customer_master_snap %}

{{
    config(
        target_database='DBT_DB_DEV',

        target_schema='INSURANCE_GOLD_DW',

        unique_key="POLICY_ID || '-' || COVERAGE_ID",

        strategy='timestamp',

        updated_at='UPDATED_TS',

        invalidate_hard_deletes=True,

        tags=['gold_dw','type2','policy','customer']
    )
}}

WITH POLICY_CURRENT AS (

    SELECT *
    FROM {{ source('insurance_silver', 'POLICY') }}
    WHERE IS_CURRENT = 'Y'

),

CUSTOMER_ALL AS (

    SELECT *
    FROM {{ source('insurance_silver', 'CUSTOMER') }}

),

POLICY_COVERAGE_ALL AS (

    SELECT *
    FROM {{ source('insurance_silver', 'POLICY_COVERAGE') }}

)

SELECT

    P.POLICY_ID,
    P.POLICY_NUMBER,
    P.POLICY_TYPE,
    P.POLICY_STATUS,

    P.PREMIUM_AMOUNT,
    P.COVERAGE_AMOUNT,

    P.POLICY_START_DATE,
    P.POLICY_END_DATE,

    C.CUSTOMER_ID,
    C.CUSTOMER_NAME,
    C.DATE_OF_BIRTH,
    C.GENDER,
    C.EMAIL,
    C.PHONE_NUMBER,
    C.CITY,
    C.STATE,

    PC.COVERAGE_ID,
    PC.COVERAGE_TYPE,
    PC.COVERAGE_LIMIT,
    PC.DEDUCTIBLE_AMOUNT,

    GREATEST(
        P.UPDATED_TS,
        C.UPDATED_TS,
        COALESCE(PC.UPDATED_TS, P.UPDATED_TS)
    ) AS UPDATED_TS,

    CURRENT_TIMESTAMP() AS DW_CREATED_TS

FROM POLICY_CURRENT P

INNER JOIN CUSTOMER_ALL C
    ON P.CUSTOMER_ID = C.CUSTOMER_ID

   AND P.POLICY_START_DATE BETWEEN
       C.EFFECTIVE_START_TS
       AND COALESCE(
            C.EFFECTIVE_END_TS,
            '9999-12-31'
       )

LEFT JOIN POLICY_COVERAGE_ALL PC
    ON P.POLICY_ID = PC.POLICY_ID

   AND P.POLICY_START_DATE BETWEEN
       PC.EFFECTIVE_START_TS
       AND COALESCE(
            PC.EFFECTIVE_END_TS,
            '9999-12-31'
       )

{% endsnapshot %}