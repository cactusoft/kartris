'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

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
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class Admin_Taxrate

    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Kartris", "PageTitle_TaxRates") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" And ConfigurationManager.AppSettings("TaxRegime").ToLower <> "simple" Then
            If Not Page.IsPostBack Then LoadTaxRates()
            mvwTax.SetActiveView(viwTaxRates)
        Else
            mvwTax.SetActiveView(viwMultistateTax)
        End If

    End Sub

    Private Sub LoadTaxRates()
        Dim tblTaxRates As New DataTable
        tblTaxRates = GetTaxRateFromCache()

        rptTaxRate.DataSource = tblTaxRates
        rptTaxRate.DataBind()
    End Sub

    Protected Sub btnUpdateTaxes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateTaxes.Click
        UpdateTaxRates()
    End Sub

    Private Sub UpdateTaxRates()
        For Each itm As RepeaterItem In rptTaxRate.Items
            If itm.ItemType = ListItemType.AlternatingItem OrElse _
            itm.ItemType = ListItemType.Item Then
                Dim intTaxID As Byte = CByte(CType(itm.FindControl("litTaxRateID"), Literal).Text)
                Dim numTaxRate As Single = HandleDecimalValues(CType(itm.FindControl("txtTaxRate"), TextBox).Text)
                Dim strQBRefCode As String = CType(itm.FindControl("txtQBRefCode"), TextBox).Text
                Dim strMessage As String = ""
                If Not TaxBLL._UpdateTaxRate(intTaxID, numTaxRate, strQBRefCode, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return
                End If
            End If
        Next
        RefreshTaxRateCache()
        LoadTaxRates()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Protected Sub rptTaxRate_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptTaxRate.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
            CType(e.Item.FindControl("txtTaxRate"), TextBox).Text = _HandleDecimalValues(CType(e.Item.FindControl("txtTaxRate"), TextBox).Text)
        End If
    End Sub
End Class
