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
Partial Class CheckoutComplete

    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Session("OrderDetails") IsNot Nothing And Session("OrderID") IsNot Nothing Then
            Dim strOrderDetails As String = Session("OrderDetails")
            If KartSettingsManager.GetKartConfig("general.email.enableHTML") = "y" Then
                litOrderDetails.Text = CkartrisBLL.ExtractHTMLBodyContents(strOrderDetails)
            Else
                litOrderDetails.Text = Replace(strOrderDetails, vbCrLf, "<br/>")
            End If

            Try
                UC_EcommerceTracking.OrderID = CInt(Session("OrderID"))
                UC_EcommerceTracking.UserID = CurrentLoggedUser.ID
            Catch ex As Exception
                'Fails
                UC_EcommerceTracking.Visible = False
            End Try
            Session("OrderID") = Nothing
            Session("OrderDetails") = Nothing
        End If
    End Sub

End Class
