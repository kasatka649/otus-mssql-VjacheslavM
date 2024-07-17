


CREATE ASSEMBLY CLRFunctiondEL FROM 
'C:\Users\MV\source\repos\CLRFunctions_1\CLRFunctions.dll'
WITH PERMISSION_SET = UNSAFE  
GO 
--DROP ASSEMBLY CLRFunctions
--GO
CREATE FUNCTION dbo.DeleteFiles    
(    
 @FolderPath AS NVARCHAR(100), 
 @DaysToKeep AS integer, 
 @FileExtension AS NVARCHAR(50)    
)     
RETURNS integer   
AS EXTERNAL NAME CLRFunctiondEL.CLRFunctions.DeleteFiles 
GO 

SELECT dbo.DeleteFiles('C:\Program Files\Microsoft SQL Server\MSSQL16.SERV22DEV\MSSQL\Backup', 120, '.bak') AS FilesDeleted 