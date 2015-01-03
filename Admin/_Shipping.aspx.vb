'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_Shipping
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Shipping", "PageTitle_Shipping") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

         If Not Page.IsPostBack Then
            GetShippingSystemData()
        End If

    End Sub

    Sub GetShippingSystemData()
        phdCalculation.Visible = False

        'Set the integrated shipping options stuff
        'to hidden, activate only below if needed
        tabPnlShippingMethods.Visible = False
        tabPnlShippingZones.Visible = False

        'Have to do these too, but in ASP.net where
        'header text still shows on tab set to be
        'not visible
        litContentTextShippingMethods.Visible = False
        litContentTextShippingZones.Visible = False


        litShippingCalculated.Visible = True
        litShippingCalculationDescription.Text = ConfigBLL._GetConfigDesc("frontend.checkout.shipping.calcbyweight")
        phdCalculation.Visible = True
        If KartSettingsManager.GetKartConfig("frontend.checkout.shipping.calcbyweight") = "y" Then
            litShippingCalculated.Text = GetGlobalResourceObject("_Shipping", "ContentText_CalculateWeight")
            chkCalcByWeight.Checked = True
        Else
            litShippingCalculated.Text = GetGlobalResourceObject("_Shipping", "ContentText_CalculateOrderValue")
            chkCalcByWeight.Checked = False
        End If
        tabPnlShippingMethods.Visible = True
        tabPnlShippingZones.Visible = True

        'Have to do these too, but in ASP.net where
        'header text still shows on tab set to be
        'not visible
        litContentTextShippingMethods.Visible = True
        litContentTextShippingZones.Visible = True

        updCollapsiblePanel.Update()

    End Sub

    Private Sub HideShippingCalculationOptions()
        CollapsiblePanelShippingCalculation.Collapsed = True
        CollapsiblePanelShippingCalculation.ClientState = "true"

        lnkBtnChangeShippingCalculation.Visible = True
        lnkBtnCancelShippingCalculation.Visible = False

        updCollapsiblePanel.Update()
    End Sub

    Private Sub ShowShippingCalculationOptions()
        CollapsiblePanelShippingCalculation.Collapsed = False
        CollapsiblePanelShippingCalculation.ClientState = "false"

        lnkBtnChangeShippingCalculation.Visible = False
        lnkBtnCancelShippingCalculation.Visible = True

        updCollapsiblePanel.Update()
    End Sub

    Protected Sub lnkBtnChangeShippingCalculation_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnChangeShippingCalculation.Click
        ShowShippingCalculationOptions()
    End Sub

    Protected Sub lnkBtnCancelShippingCalculation_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelShippingCalculation.Click
        HideShippingCalculationOptions()
    End Sub

    Protected Sub lnkBtnSaveShippingCalculation_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveShippingCalculation.Click
        Dim strUseWeight As String = "n"
        If chkCalcByWeight.Checked Then strUseWeight = "y"
        If ConfigBLL._UpdateConfigValue("frontend.checkout.shipping.calcbyweight", strUseWeight) Then
            GetShippingSystemData()
            HideShippingCalculationOptions()
        End If

        ShowMasterUpdateMessage()
    End Sub

    Protected Sub _UC_ShippingMethods_UpdateSaved() Handles _UC_ShippingMethods.UpdateSaved
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub _UC_ShippingZones_UpdateSaved() Handles _UC_ShippingZones.UpdateSaved
        ShowMasterUpdateMessage()
    End Sub

    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

End Class
