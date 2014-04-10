'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_Back_AdminFTS
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Try
                LoadFTSInformation()
            Catch ex As Exception
                mvwFTS.SetActiveView(viwNotSupported)
                updMain.Update()
            End Try
        End If
    End Sub

    Sub LoadFTSInformation()
        Dim blnKartrisCatalogExist As Boolean, blnKartrisFTSEnabled As Boolean, _
                strKartrisFTSLanguages As String = "", blnFTSSupported As Boolean, strMsg As String = ""
        KartrisDBBLL._GetFTSInformation(blnKartrisCatalogExist, blnKartrisFTSEnabled, strKartrisFTSLanguages, blnFTSSupported, strMsg)
        If blnFTSSupported Then
            If blnKartrisCatalogExist AndAlso blnKartrisFTSEnabled Then
                If strKartrisFTSLanguages.Contains("Neutral") Then
                    strKartrisFTSLanguages = strKartrisFTSLanguages.Replace("Neutral", "<b>Neutral*</b>")
                    litNeutralLanguages.Visible = True
                End If
                If strKartrisFTSLanguages.EndsWith("##") Then strKartrisFTSLanguages = strKartrisFTSLanguages.TrimEnd("##")
                litFTSLanguages.Text = strKartrisFTSLanguages.Replace("##", ", ")
                mvwFTS.SetActiveView(viwEnabled)
            Else
                mvwFTS.SetActiveView(viwNotEnabled)
            End If
        Else
            mvwFTS.SetActiveView(viwNotSupported)
        End If
        updMain.Update()
    End Sub

    Protected Sub lnkSetupFTS_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkSetupFTS.Click
        KartrisDBBLL.SetupFTS()
        ConfigBLL._UpdateConfigValue("general.fts.enabled", "y")
        LoadFTSInformation()
    End Sub

    Protected Sub lnkStopFTS_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkStopFTS.Click
        KartrisDBBLL.StopFTS()
        ConfigBLL._UpdateConfigValue("general.fts.enabled", "n")
        LoadFTSInformation()
    End Sub
End Class
