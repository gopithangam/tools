/******  Get DISTINCT SoureReleaseDate from EXTERNAL_FIXLETS  ******/
SELECT DISTINCT Convert(date, [SourceReleaseDate]) as StringToDate
  FROM [BFEnterprise].[dbo].[EXTERNAL_FIXLETS]
  WHERE [SourceReleaseDate] IS NOT NULL