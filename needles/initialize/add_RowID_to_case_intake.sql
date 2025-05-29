/*
Adds identity column ROW_ID to case_intake
*/

USE [Needles]
GO

ALTER TABLE case_intake
ADD ROW_ID INT IDENTITY(1,1)