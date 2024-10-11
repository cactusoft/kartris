'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_Destinations
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Shipping", "PageTitle_ShippingDestinationCountries") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            _UC_ZoneDestinations.GetZoneDestinations()
        End If

    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        KartSettingsManager.SetKartConfig("frontend.checkout.defaultcountry", ddlCountry.SelectedValue)
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_ZoneDestinations.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
    Protected Sub ddlCountry_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCountry.DataBound
        Dim intDefaultCountryConfig As Integer = CInt(KartSettingsManager.GetKartConfig("frontend.checkout.defaultcountry"))
        For Each itmCountry As ListItem In ddlCountry.Items
            If itmCountry.Value = intDefaultCountryConfig Then
                ddlCountry.SelectedValue = itmCountry.Value
                Exit For
            End If
        Next

        litDefaultDesc.Text = ConfigBLL._GetConfigDesc("frontend.checkout.defaultcountry")
    End Sub
End Class
