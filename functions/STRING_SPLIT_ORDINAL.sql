IF OBJECT_ID (N'dbo.STRING_SPLIT_ORDINAL', N'FN') IS NOT NULL
    DROP FUNCTION STRING_SPLIT_ORDINAL;
GO

CREATE FUNCTION dbo.STRING_SPLIT_ORDINAL
(
    @input NVARCHAR(MAX),
    @separator NCHAR(1)
)
RETURNS TABLE
AS
RETURN
WITH
-- Generate a tally table (numbers up to 8,000)
E1(N) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
          UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
E2(N) AS (SELECT 1 FROM E1 a CROSS JOIN E1 b),       -- 64
E4(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2 a CROSS JOIN E2 b), -- 4096+
Tally(N) AS (SELECT TOP (LEN(@input) + 1) N FROM E4 ORDER BY N),

-- Identify the positions of each separator (and the start of string)
Positions AS (
    SELECT 0 AS Pos
    UNION ALL
    SELECT N
    FROM Tally
    WHERE SUBSTRING(@input, N, 1) = @separator
),

-- Pair each position with the next one to get start and end of each token
Boundaries AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Pos) AS ordinal,
        Pos + 1 AS StartPos,
        LEAD(Pos, 1, LEN(@input) + 1) OVER (ORDER BY Pos) - Pos - 1 AS Length
    FROM Positions
)

SELECT 
    LTRIM(RTRIM(SUBSTRING(@input, StartPos, Length))) AS value,
    ordinal
FROM Boundaries
WHERE Length > 0;  -- skip empty parts if any