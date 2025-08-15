# 1_Contact

| Script Name | Description | Dependencies |
|-------------|-------------|-------------|
| 00__IndvContacts__fallback.sql | Create unidentified individual contacts to be used as fallbacks where applicable | [None] |
| 00__OrgContacts__fallback.sql | Create unidentified organization contacts to be used as fallbacks where applicable | [None] |
| 01__IndvContacts__names.sql | Insert Individual Contacts from [names] | [None] |
| 02__IndvContacts__police.sql | Insert Individual Contacts from [police] | [None] |
| 03__IndvContacts__staff.sql | Insert Individual Contacts from [staff] | [None] |
| 04__IndvContacts__insurance.sql | Insert Individual Contacts from [insurance] | [None] |
| 05__IndvContacts__comments.sql | Update Individual Contact comments | ['initialize\\02__create__party_indexed.sql'] |
| 10__OrgContacts__names.sql | Insert Organization Contacts from [names] | [None] |
| 15__Users.sql | Insert Users | ['\\conversion\\1_contact\\03__IndvContacts__staff.sql'] |
| 20__Address__IndvContacts.sql | Insert addresses from [IndvContacts] | ['\\conversion\\1_contact\\01__IndvContacts__names.sql'] |
| 21__Address__OrgContacts.sql | Insert addresses from [OrgContacts] | ['\\1_contact\\10__OrgContacts__names.sql'] |
| 22__Address__appendix.sql | Ensures each individual/organization contact has an [sma_MST_Address] record | ['\\1_contact\\20__Address__IndvContacts.sql', '\\1_contact\\21__Address__OrgContacts.sql'] |
| 30__ContactNumbers__utility.sql | Update contact types for attorneys | No metadata found |
| 31__ContactNumbers__IndvContacts.sql | Insert Users | ['\\conversion\\1_contact\\01__IndvContacts__names.sql', '\\conversion\\1_contact\\20__Address__IndvContacts.sql'] |
| 32__ContactNumbers__OrgContacts.sql | Insert Users | ['\\conversion\\1_contact\\01__IndvContacts__names.sql', '\\conversion\\1_contact\\20__Address__IndvContacts.sql'] |
| 40__EmailWebsite__IndvContacts.sql | Update contact types for attorneys | No metadata found |
| 40__EmailWebsite__OrgContacts.sql | Update contact types for attorneys | No metadata found |
| 90__Uniqueness.sql | None | No metadata found |
| 91__AllContactInfo.sql | None | No metadata found |
| 92__IndvOrgContacts_Indexed.sql | None | No metadata found |
| 99__Notes__contacts.sql | No metadata found | No metadata found |
