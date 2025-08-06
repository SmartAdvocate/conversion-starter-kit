USE   [SAbilleasterlyLaw]
GO

----------------------------------------
--INSERT EMPLOYER NAMES
----------------------------------------
--
ALTER TABLE [sma_MST_OrgContacts] DISABLE TRIGGER ALL
GO
--
INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[connContactCtg],
		[connContactTypeID],
		[connRecUserID],
		[condDtCreated],
		[saga],
		[saga_ref]
	)
SELECT DISTINCT
		 p.[data] 				as [consName],
		2							as [connContactCtg],
		(select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octnContactCtgID=2 and octsDscrptn='General') as [connContactTypeID],
		368							as [connRecUserID],	
		getdate()					as [condDtCreated],
		'-2'						as [saga],
		p.namesid 			as [saga_ref]
FROM [NeosBillEasterly].[dbo].[user_tab3_data] p
join  [NeosBillEasterly].[dbo].[user_case_fields] ucf on ucf.id = p.usercasefieldid
WHERE ucf.field_title in ( 'Name','Other')
and isnull(p.[data],'')<>''
GO
--
ALTER TABLE [sma_MST_OrgContacts] ENABLE TRIGGER ALL
GO
--

