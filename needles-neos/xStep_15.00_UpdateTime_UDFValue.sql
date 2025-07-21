select *
from sma_TRN_UDFValues
where  udvsUDFValue like '[0-2][0-9]:[0-5][0-9]:[0-5][0-9].000'

UPDATE sma_TRN_UDFValues
SET udvsUDFValue = FORMAT(CAST(udvsUDFValue AS time), 'h:mm tt')
WHERE ISDATE(udvsUDFValue) = 1
  AND udvsUDFValue LIKE '[0-2][0-9]:[0-5][0-9]:[0-5][0-9].000'


 
