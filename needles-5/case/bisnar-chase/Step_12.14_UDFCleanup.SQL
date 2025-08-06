use SA
GO

ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO

--UPDATE FORMAT OF DATE
UPDATE sma_trn_udfvalues
SET udvsUDFValue = case when isdate(udvsudfvalue) = 1 and convert(datetime,udvsudfvalue) between '1/1/1900' and '6/6/2079' 
		then convert(Varchar,convert(datetime, udvsUDFValue),101) else udvsudfvalue end
FROM sma_trn_udfvalues v
JOIN sma_MST_UDFDefinition d on v.udvnUDFID = d.udfnUDFID
WHERE  udfsType = 'Date'
and isnull(udvsudfvalue,'')<>''


--UPDATE FORMAT OF checkbox
UPDATE sma_trn_udfvalues
SET udvsUDFValue = case when udvsUDFValue  ='true' then 1 
						when udvsUDFValue  ='false' then 0  else '' end
--Select *
FROM sma_trn_udfvalues v
JOIN sma_MST_UDFDefinition d on v.udvnUDFID = d.udfnUDFID
WHERE udfsType = 'Checkbox'
and isnull(udvsUDFValue,'') in ('true','false')


ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
go

UPDATE sma_MST_UDFDefinition 
SET udfstype = 'Date'
WHERE udfsType = 'date'

UPDATE sma_MST_UDFDefinition 
SET udfstype = 'Time'
WHERE udfsType = 'time'

UPDATE sma_MST_UDFDefinition 
SET udfstype = 'Number'
WHERE udfsType = 'number'

UPDATE sma_MST_UDFDefinition 
SET udfstype = 'CheckBox'
WHERE udfsType = 'checkbox'

UPDATE sma_MST_UDFDefinition 
SET udfstype = 'Text'
WHERE udfsType IN ('text','Staff')
