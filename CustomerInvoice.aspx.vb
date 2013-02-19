'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Customer_Invoice

    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim numOrderID, numCustomerID As Integer

        'Bump customer out if not authenticated
        If Not (User.Identity.IsAuthenticated) Then
            Response.Redirect("~/CustomerAccount.aspx")
        Else
            numCustomerID = DirectCast(Membership.GetUser(), KartrisMemberShipUser).ID
        End If

        'Display invoice
        Try
            numOrderID = CLng(Request.QueryString("O_ID"))
            UC_Invoice.CustomerID = numCustomerID
            UC_Invoice.OrderID = numOrderID
            UC_Invoice.FrontOrBack = "back" 'tell user control is on back end
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            HttpContext.Current.Server.Transfer("~/Error.aspx")
        End Try

    End Sub

End Class
