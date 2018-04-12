'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports System.Web.HttpContext

Public Class FeedsBLL
    'We don't use table adaptors here, as it's far simpler to set a long
    'command timeout this way, and pulling all the product on the site is
    'often something that would otherwise time out on a big site
    Public Shared Function _GetFeedData() As DataTable
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdExecuteQuery As SqlCommand = sqlConn.CreateCommand
            cmdExecuteQuery.CommandText = "_spKartrisFeeds_GetItems"

            cmdExecuteQuery.CommandType = CommandType.StoredProcedure
            cmdExecuteQuery.CommandTimeout = 3600

            Try
                Dim tblExport As New DataTable()
                Using adptr As New SqlDataAdapter(cmdExecuteQuery)
                    adptr.Fill(tblExport)
                    Return tblExport
                End Using
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            Finally
            End Try
        End Using
        Return Nothing
    End Function
End Class
