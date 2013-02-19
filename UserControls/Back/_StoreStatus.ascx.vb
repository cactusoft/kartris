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
Imports KartSettingsManager

Partial Class UserControls_Back_StoreStatus
    Inherits System.Web.UI.UserControl

    'Create property we can check from elsewhere
    Private _IsOpen As Boolean

    'We use this property to control the colour of
    'the store status indicator (red/green)
    Public Shared ReadOnly Property IsOpen() As Boolean
        Get
            Return GetKartConfig("general.storestatus") = "open"
        End Get
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            btnCloseStore.ToolTip = GetGlobalResourceObject("_Kartris", "ContentText_TheShopIsOpen") & " - " & GetGlobalResourceObject("_Kartris", "ContentText_CloseTheShop")
            btnOpenStore.ToolTip = GetGlobalResourceObject("_Kartris", "ContentText_TheShopIsClosed") & " - " & GetGlobalResourceObject("_Kartris", "ContentText_OpenTheShop")

            CheckStore()
        End If
    End Sub

    Sub CheckStore()
        If GetKartConfig("general.storestatus") = "open" Then
            mvwStoreStatus.SetActiveView(viwOpen)
        Else
            mvwStoreStatus.SetActiveView(viwClosed)
        End If
    End Sub

    Protected Sub btnOpenStore_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnOpenStore.Click
        If ConfigBLL._UpdateConfigValue("general.storestatus", "open") Then
            RefreshCache()
            CheckStore()
        End If
    End Sub

    Protected Sub btnCloseStore_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCloseStore.Click
        If ConfigBLL._UpdateConfigValue("general.storestatus", "locked") Then
            RefreshCache()
            CheckStore()
        End If
    End Sub
End Class
