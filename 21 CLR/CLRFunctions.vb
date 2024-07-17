Imports System.IO  

Public Class CLRFunctions     

   Public Shared Function DeleteFiles(sPath As String, iDaysToKeep As Integer, sFileExtension As String) As Integer    

      Dim arrFiles As Array  
      Dim dateToday As Date  
      Dim myFileInfo As FileInfo  
      Dim myDirectoryInfo As DirectoryInfo  
      Dim iFileCount As Integer  

      Try     
         iFileCount = 0  

         myDirectoryInfo = New DirectoryInfo(sPath)  

         arrFiles = myDirectoryInfo.GetFiles()  

         dateToday = DateAdd("d", -iDaysToKeep, Today)  

         For Each myFileInfo In arrFiles  
            If myFileInfo.Extension = sFileExtension And myFileInfo.LastWriteTime < dateToday Then  
               myFileInfo.Delete()  
               iFileCount = iFileCount + 1                  
            End If  
         Next  

         Return iFileCount  
           
      Catch 
         Return 0          
      End Try 

   End Function    

End Class
