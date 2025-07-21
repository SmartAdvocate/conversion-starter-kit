USE   [SAbilleasterlyLaw]
GO

if exists (select * from sys.tables where name = 'InsuredHelper')
begin
	drop table InsuredHelper
end

create table InsuredHelper (Insured varchar(100), wordct int, firstname varchar(30), middle varchar(30), lastname varchar(80), company varchar(100))

INSERT INTO InsuredHelper (Insured, wordct)
SELECT DISTINCT insured, dbo.WordCount(Insured)
FROM  [NeosBillEasterly].[dbo].[insurance] INS
WHERE isnull(insured,'')<>''
----- select * from InsuredHelper

update InsuredHelper 
set company = Insured
where wordct not in (2,3,4) 

update InsuredHelper 
set company = Insured
from InsuredHelper
where isnull(company, '')<> ''  
 and (insured like '%inc%' or insured like '%llc%' or insured like '%freight%' or insured like '%auto%'
	or insured like '%solution%' or insured like '%hauler%' or insured like '% and %'  or insured like '%realty%' 
	or insured like '%apartment%' or insured like '% LP%' or insured like '% truck%' or insured like '% & %' 
	or insured like '%pizza%' or insured like '%company%' or insured like '%plaza%' or insured like '%trust%'
	or insured like '% by %' or insured like '%construction%' or insured like '%transfer%' or insured like '%supermercado%'
	or insured like '%management%' or insured like '%partner%' or insured like '%.com%' or insured like '%insurance%'
	or insured like '%commercial%' or insured like '%county%' or insured like '%school%' or insured like '%health%'
	or insured like '% car %' or insured like '%academy%' or insured like '% mart' or insured like '%insured%'
	or insured like '%[0-9]%' or insured like '%grocery%' or insured like '%church%' or insured like '%depot%'
	or insured like '%assistance%' or insured like '%hospital%' or insured like '%marriott%' or insured like '%corporation%'
	or insured like '%suite%' or insured like '%transport%' or insured like '%underground%' or insured like '%plumbing%'
	or insured like '%claim%' or insured like '%police%' or insured like '%sausage%' or insured like '%southwest%'
	or insured like '%houston%' or insured like '%moving%' or insured like '%market%' or insured like '%children%' 
	or insured like '%wheelhouse%' or insured like '%LTD%' or insured like '% UM %' or insured like '%coverage%'
	or insured like '% pip %' or insured like '%rental%' or insured like '%holding%' or insured like '%laboratories%'
	or insured like '%service%' or insured like '%diagnostic%' or insured like '%enterprise%' or insured like '%L.P.%'
	or insured like 'The %' or insured like '%texas%' or insured like '%complete%' )
GO     

update InsuredHelper
set company = Insured
where Insured = 'A''Lexus Kinnard'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'A. Schulman, Inc.'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'A.D. Transport Express'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'ABC Employment Holdings, LLC'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Ace American Insurance Company'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Advanced Composites, Inc.'


update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Advantage Solutions '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Advantage Staffing '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Agri-Chem LLC '

update InsuredHelper
set company = '',
      firstname = 'Albert',
	  lastname = 'McCall'
where Insured = 'Albert McCall II '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Alcatel-Lucent Technologies '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'All Around Industrial '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Alsco, Inc '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
where Insured = 'Amedisys of Nashville Eas '

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'America''s Car Mart';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'American Constructors, Inc.';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'American HomePatient, Inc';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'American Signature, Inc.';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Arrow Exterminators, Inc.';


update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Asplundh Tree Expert Company';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Associated Wholesale Grocers';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Asurion Corp';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'AT&T';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'AT&T Mobility Services, LLC';


update InsuredHelper
set company = '',
      firstname = 'Kittie',
	  lastname = 'Atencio'
WHERE Insured = 'Atencio, Ms. Kittie';

update InsuredHelper
set company = '',
      firstname = 'August ',
	  lastname = 'Ruff'
WHERE Insured = 'August Ruff (Owner)';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'B&K Trucking LLC';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Banfield Pet Hospital';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Bates Acquistion, LLC';

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Bauer''s Family Restaurant'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Beaman Automotive Parts'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'BellSouth Telecommunications, Inc.'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Best American Hospitality Corp'


update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Bravo Leasing, LLC'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Brookdale Senior Living, Inc.'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Brookdale Senior Living'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'CareFirst BlueCross BlueShield'

 update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Carlex Glass America, LLC'

 update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Carriage House Inn'

 update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Charter Communications for Spectrum'

 update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'City of Franklin'

update InsuredHelper
set company = Insured,
      firstname = '',
	  lastname = ''
WHERE Insured = 'Zelenka Nursery, LLC'



update InsuredHelper
set company = '',
      firstname = 'Waffa ',
	  lastname = 'Beshay'
WHERE Insured = 'Waffa Beshay (mother)'




----- select * from InsuredHelper
---------------------------------------------
--CREATE CONTACT CARDS FOR INSURED
---------------------------------------------
--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO

ALTER TABLE sma_MST_IndvContacts
ALTER COLUMN saga INT NULL;
--
INSERT INTO [sma_MST_IndvContacts] (
	[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade], [saga_ref]) 
SELECT DISTINCT 
	1			as [cinbPrimary],
	10			as [cinnContactTypeID],
	null,'',
	Firstname	as [cinsFirstName],
	middle		as [cinsMiddleName],
	lastname	as [cinsLastName], 
	null		as [cinsSuffix],
	null		as [cinsNickName],
	1			as [cinbStatus],
	null		as [cinsSSNNo],
	null		as [cindBirthDate],
	null,
	1			as [cinnContactCtg],
	'','',null,'','',1,'',1,1,null,null,'','',null,0,
	368			as [cinnRecUserID],
	GETDATE()	as [cindDtCreated],
	''			as [cinnModifyUserID],
	null		as [cindDtModified],
	0,'','','','',
	null		as [cinsHeight],
	null		as [cinnWeight],
	'',Null,'','','','',
	-1			as [saga],
	''			as [cinsSpouse],
	NULL		as [cinsGrade], 
	insured		as [saga_ref]
FROM InsuredHelper
WHERE firstname IS NOT NULL
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO


ALTER TABLE [sma_MST_OrgContacts] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga],
		[neos_saga]
	)
SELECT 
    company			as [consName],
    NULL			as [consWorkPhone],
	''				as [consComments],
    2				as [connContactCtg],
    (select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) as [connContactTypeID],
    368				as [connRecUserID],
    getdate()		as [condDtCreated],
    1				as [conbStatus],		-- Hardcode Status as ACTIVE
    -1				as [saga],
	Insured			as [neos_saga]
--SELECT *
FROM InsuredHelper
WHERE Company IS NOT NULL
GO

ALTER TABLE [sma_MST_OrgContacts] ENABLE TRIGGER ALL
GO