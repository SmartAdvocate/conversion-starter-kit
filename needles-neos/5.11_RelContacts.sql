USE  [SAbilleasterlyLaw]
GO


 alter table sma_MST_RelContacts disable trigger all
delete from sma_MST_RelContacts
DBCC CHECKIDENT ('sma_MST_RelContacts', RESEED, 0);
alter table sma_MST_RelContacts enable trigger all

INSERT INTO sma_MST_RelContacts ( rlcnPrimaryCtgID
                                                               , rlcnPrimaryContactID
															   , rlcnPrimaryAddressID
															   , rlcnRelCtgID
															   , rlcnRelContactID
															   , rlcnRelAddressID
															   , rlcnRelTypeID
															   , rlcnRecUserID
															   , rlcdDtCreated
															   , rlcsBizFam)
SELECT  distinct 
		ind.cinnContactCtg				as rlcnPrimaryCtgID,                             	
		ind.cinnContactID				as rlcnPrimaryContactID,                    	
		ai.addnAddressID			as rlcnPrimaryAddressID,                  
		org.connContactCtg			as rlcnRelCtgID, 
		org.connContactID			as rlcnRelContactID, 
		ao.addnAddressID			as rlcnRelAddressID, 
		2							as rlcnRelTypeID, 
		368							as rlcnRecUserID, 
		getdate()					as rlcdDtCreated, 
		'Business'					as rlcsBizFam
---- select distinct et.*,  ai.addnAddressID, ao.addnAddressID	
FROM   [NeosBillEasterly].[dbo].[multi_addresses] et
JOIN sma_MST_IndvContacts ind    ON CONVERT(varchar(50), ind.saga) = CONVERT(varchar(50), et.namesid)
JOIN sma_mst_address ai on ai.addnContactID = ind.cinnContactID and ai.addnContactCtgID = 1
JOIN sma_MST_OrgContacts org ON CONVERT(varchar(50), org.saga) = CONVERT(varchar(50), et.namesid)        
JOIN sma_mst_address ao on ao.addnContactID = org.connContactID and ao.addnContactCtgID = 2