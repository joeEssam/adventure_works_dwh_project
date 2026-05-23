use data_warehouse;

select 
    CID,
    BDATE,
    GEN
from [data_warehouse].silver.[erp_cust_az12]
where CID NOT in (select cst_key from silver.crm_cust_info) 

select * from [data_warehouse].silver.[erp_cust_az12]
where BDATE not between '1900-01-01' and '2024-12-31'


select * from [data_warehouse].silver.[erp_cust_az12]
where GEN != TRIM(GEN)

SELECT DISTINCT GEN from [data_warehouse].silver.[erp_cust_az12]

select * from [data_warehouse].silver.[erp_cust_az12]
where trim(GEN) not in ('Male','Female','n\a')


---------------------------------------------------------------------

select * 
from [data_warehouse].silver.[erp_loc_a101]
where CID is null or CNTRY is null

select * from [data_warehouse].silver.[erp_loc_a101]
where CNTRY != trim(CNTRY)

select distinct CNTRY from [data_warehouse].silver.[erp_loc_a101]

select * from [data_warehouse].silver.[erp_loc_a101]
where CID != trim(CID)


----------------------------------------------------------------------



select * from [data_warehouse].silver.[erp_px_cat_g1v2]
where ID not in (select prd_cat from [data_warehouse].silver.crm_prd_info) ;

select * from [data_warehouse].silver.[erp_px_cat_g1v2] 
where ID  != trim(ID) or CAT != trim(CAT) or SUBCAT != trim(SUBCAT) or MAINTENANCE != trim(MAINTENANCE) ;

select distinct CAT from [data_warehouse].silver.[erp_px_cat_g1v2] ;

select distinct SUBCAT from [data_warehouse].silver.[erp_px_cat_g1v2] ;

select distinct MAINTENANCE from [data_warehouse].silver.[erp_px_cat_g1v2] ;