'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Web.HttpContext
Imports kartrisStockNotificationsDataTableAdapters
Imports CkartrisFormatErrors
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Public Class StockNotificationsBLL

    Private Shared _Adptr As StockNotificationsTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr() As StockNotificationsTblAdptr
        Get
            _Adptr = New StockNotificationsTblAdptr
            Return _Adptr
        End Get
    End Property

    Private Shared _Adptr2 As VersionsAwaitingTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr2() As VersionsAwaitingTblAdptr
        Get
            _Adptr2 = New VersionsAwaitingTblAdptr
            Return _Adptr2
        End Get
    End Property

    ''' <summary>
    ''' This sub can be called from the
    ''' ProductVersions.ascx.vb in response to
    ''' button clicks on notify-me buttons to
    ''' show the popup for users to enter their
    ''' email address into.
    ''' </summary>
    ''' <param name="strUserEmail">Email of customer requesting the notification</param>
    ''' <param name="numVersionID">ID of the version they wish to be notified about</param>
    ''' <param name="strPageLink">The link to the page where this item is</param>
    ''' <param name="strProductName">Name of product</param>
    ''' <param name="numLanguageID">Language ID</param> 
    Public Shared Sub AddNewStockNotification(ByVal strUserEmail As String,
                                              ByVal numVersionID As Int64,
                                              ByVal strPageLink As String,
                                              ByVal strProductName As String,
                                              ByVal numLanguageID As Byte)

        'Couple of values not passed in
        Dim datDateCreated As DateTime = Now()
        Dim strStatus As String = "w" 'waiting to be sent!
        Dim strUserIP As String = CkartrisEnvironment.GetClientIPAddress()

        'Connection string
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()

        'Connect to sproc and send over the info
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdAddStockNotification As SqlCommand = sqlConn.CreateCommand
            cmdAddStockNotification.CommandText = "spKartrisStockNotification_Add"
            Dim savePoint As SqlTransaction = Nothing
            cmdAddStockNotification.CommandType = CommandType.StoredProcedure
            Try
                cmdAddStockNotification.Parameters.AddWithValue("@UserEmail", strUserEmail)
                cmdAddStockNotification.Parameters.AddWithValue("@VersionID", numVersionID)
                cmdAddStockNotification.Parameters.AddWithValue("@PageLink", strPageLink)
                cmdAddStockNotification.Parameters.AddWithValue("@ProductName", strProductName)
                cmdAddStockNotification.Parameters.AddWithValue("@OpenedDate", datDateCreated)
                cmdAddStockNotification.Parameters.AddWithValue("@UserIP", strUserIP)
                cmdAddStockNotification.Parameters.AddWithValue("@LanguageID", numLanguageID)
                cmdAddStockNotification.Parameters.AddWithValue("@newSNR_ID", 0)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdAddStockNotification.Transaction = savePoint

                cmdAddStockNotification.ExecuteNonQuery()
                savePoint.Commit()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Sub

    ''' <summary>
    ''' Update stock notification record when it is sent
    ''' with date and changed status
    ''' </summary>
    ''' <param name="numSNR_ID">The ID of the stock notification to update</param>
    Public Shared Sub _UpdateStockNotification(ByVal numSNR_ID As Int64)

        'Couple of values not passed in
        Dim datDateSettled As DateTime = Now()
        Dim strStatus As String = "s" 'sent!

        'Connection string
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()

        'Connect to sproc and send over the info
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateStockNotification As SqlCommand = sqlConn.CreateCommand
            cmdUpdateStockNotification.CommandText = "_spKartrisStockNotification_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateStockNotification.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateStockNotification.Parameters.AddWithValue("@SNR_ID", numSNR_ID)
                cmdUpdateStockNotification.Parameters.AddWithValue("@DateSettled", datDateSettled)
                cmdUpdateStockNotification.Parameters.AddWithValue("@strStatus", strStatus)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateStockNotification.Transaction = savePoint

                cmdUpdateStockNotification.ExecuteNonQuery()
                savePoint.Commit()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Sub

    ''' <summary>
    ''' Update version to reset bulktimestamp date. This is used
    ''' when processing bulk notifications in back end, so we
    ''' know which versions were updated
    ''' </summary>
    ''' <param name="numV_ID">The version ID to update</param>
    Public Shared Sub _UpdateVersionResetTimeStamp(ByVal numV_ID As Int64)

        'Connection string
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()

        'Connect to sproc and send over the info
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdate As SqlCommand = sqlConn.CreateCommand
            cmdUpdate.CommandText = "_spKartrisVersions_UpdateBulkTimeStamp"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdate.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdate.Parameters.AddWithValue("@V_ID", numV_ID)
                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdate.Transaction = savePoint

                cmdUpdate.ExecuteNonQuery()
                savePoint.Commit()
            Catch ex As Exception
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
                If Not savePoint Is Nothing Then savePoint.Rollback()
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
    End Sub

    ''' <summary>
    ''' This sub is called whenever a version is updated, stock
    ''' tracking is enabled and the current item is in
    ''' stock
    ''' </summary>
    ''' <param name="numVersionID">ID of the version they wish to be notified about</param>
    Public Shared Function _SearchSendStockNotifications(ByVal numVersionID As Int64) As Integer

        'Look up all pending notifications for this
        'version ID
        Dim tblStockNotifications As New DataTable
        tblStockNotifications = _GetStockNotificationsByVersionID(numVersionID, "w")

        'How many stock notifications
        Dim numRecords As Integer = tblStockNotifications.Rows.Count
        'Ok, now we have a datatable of stock notifications, we work through
        'one by one, send the notification and update the record to indicate
        'has been sent.
        For Each drwStockNotification In tblStockNotifications.Rows

            Dim numID As Int64 = drwStockNotification("SNR_ID")
            Dim strEmailTo As String = drwStockNotification("SNR_UserEmail")
            Dim strPageLink As String = drwStockNotification("SNR_PageLink")
            Dim strProductName As String = drwStockNotification("SNR_ProductName")
            Dim numLanguageID As Byte = drwStockNotification("SNR_LanguageID")

            'Email to send from depends on language ID
            Dim strFromEmail As String = LanguagesBLL.GetEmailFrom(numLanguageID)

            'Retrieve the template for the user's language ID
            Dim strEmailTemplateText As String = RetrieveHTMLEmailTemplate("StockNotification", numLanguageID)

            'Set email body to template text
            Dim strEmailBody As String = strEmailTemplateText

            'Put pagelink and product name into mail
            strEmailBody = strEmailBody.Replace("[pagelink]", CkartrisBLL.WebShopURLhttp & strPageLink.Substring(1, strPageLink.Length - 1))
            strEmailBody = strEmailBody.Replace("[productname]", Current.Server.HtmlEncode(strProductName))

            strEmailBody = strEmailBody.Replace("[pagelink]", GetGlobalResourceObject("Kartris", "Config_Webshopname"))
            strEmailBody = Replace(strEmailBody, "[productname]", Current.Server.HtmlEncode(strProductName))

            'Subject line
            Dim strSubject As String = GetGlobalResourceObject("_StockNotification", "ContentText_StockNotification")

            'Send email
            SendEmail(strFromEmail, strEmailTo, strSubject, strEmailBody, , , , , True)

            'LogError(strEmailBody)
            'Update notification record to confirm as sent
            _UpdateStockNotification(numID)
        Next

        Return numRecords
    End Function

    ''' <summary>
    ''' Returns database of stock notifications for the
    ''' specified Version ID
    ''' </summary>
    ''' <param name="numVersionID">ID of the version they wish to be notified about</param>
    Public Shared Function _GetStockNotificationsByVersionID(ByVal numVersionID As Int64, ByVal strStatus As String) As DataTable
        Return Adptr._GetStockNotificationsByVersionID(numVersionID, strStatus)
    End Function

    ''' <summary>
    ''' Returns datatable of versions which need
    ''' to have notification checks run on them 
    ''' (i.e. versions uploaded via data tool, etc.
    ''' where stock notification check doesn't run)
    ''' </summary>
    Public Shared Function _GetVersions() As DataTable
        Return Adptr2._GetVersions()
    End Function

    ''' <summary>
    ''' Produces a count of versions that need to
    ''' have stock notification checks run against
    ''' them.
    ''' </summary>
    Public Shared Function _GetCountVersionsAwaitingChecks() As Int64
        Dim dtbVersions As DataTable = _GetVersions()
        Return dtbVersions.Rows.Count
    End Function

    ''' <summary>
    ''' Returns table of unfulfilled stock notification
    ''' requests, including name of product/version they're
    ''' waiting for and P_ID, V_ID we can use to link to
    ''' those items
    ''' </summary>
    Public Shared Function _GetStockNotificationsDetails(ByVal strStatus As String) As DataTable
        Dim dtbDetails As DataTable = Adptr._GetStockNotificationsDetails(strStatus)
        Return dtbDetails
    End Function

    ''' <summary>
    ''' Loop through the versions that have been bulk
    ''' updated and check for notifications
    ''' </summary>
    Public Shared Function _RunBulkCheck() As Boolean
        'Let's get a datatable with versions that need to check
        Dim dtbVersions As DataTable = _GetVersions()
        For Each drwVersion In dtbVersions.Rows
            _SearchSendStockNotifications(drwVersion("V_ID"))
            _UpdateVersionResetTimeStamp(drwVersion("V_ID"))
        Next
        Return True
    End Function
End Class
