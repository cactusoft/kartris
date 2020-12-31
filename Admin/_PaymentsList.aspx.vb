'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_PaymentsList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "ContentText_Payments") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
                _UC_PaymentsList.RefreshPaymentsList()
        End If
        txtSearch.Focus()
    End Sub


    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click

        'Handle search for payment number
        'Don't check we find one, quicker
        'this way.
        If IsNumeric(txtSearch.Text) Then
            'Search by Payment ID
            Dim intPaymentID As Integer = CInt(txtSearch.Text)
            Response.Redirect("_ModifyPayment.aspx?PaymentID=" & intPaymentID)
        End If

        'Reset the order list's pager control
        _UC_PaymentsList.ResetCurrentPage()
        
            If IsDate(txtSearch.Text) Then
                'Date search
            _UC_PaymentsList.datValue1 = txtSearch.Text
            _UC_PaymentsList.datGateway = Nothing
                _UC_PaymentsList.CallMode = "d"
            Else
                _UC_PaymentsList.CallMode = "g"
                _UC_PaymentsList.datValue1 = Nothing
                _UC_PaymentsList.datGateway = txtSearch.Text
            End If
        _UC_PaymentsList.RefreshPaymentsList()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_PaymentsList.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub
End Class

