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
Imports CkartrisEnumerations
Imports KartSettingsManager
Imports System.Web.HttpContext

Partial Class Admin_StockNotifications
    Inherits _PageBaseClass

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_StockNotification", "ContentText_StockNotifications") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            Dim intRowsPerPage As Integer = 25
            Try
                intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
            Catch ex As Exception
                'Stays at 25
            End Try
            gvwDetails.PageSize = intRowsPerPage

            LoadStockNotifications()

            'Hide the button and gvw if no items awaiting checks
            If gvwDetails.Rows.Count = 0 Then phdCurrentNotifications.Visible = False Else phdCurrentNotifications.Visible = True
        End If
    End Sub

    'Run notifications check button pushed
    Protected Sub btnCheckAndSend_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCheckAndSend.Click
        StockNotificationsBLL._RunBulkCheck()
        LoadStockNotifications()
        updStockNotifications.Update()
        RaiseEvent ShowMasterUpdate()
    End Sub

    'Load up and refresh the gridviews
    Private Sub LoadStockNotifications()
        gvwDetails.DataSource = StockNotificationsBLL._GetStockNotificationsDetails("w")
        gvwDetails.DataBind()
        gvwDetailsClosed.DataSource = StockNotificationsBLL._GetStockNotificationsDetails("s")
        gvwDetailsClosed.DataBind()
    End Sub
End Class
