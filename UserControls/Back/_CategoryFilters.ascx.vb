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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisImages
Imports KartSettingsManager
Imports System.Linq

Partial Class UserControls_Back_CategoryFilters
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            txtXML.Text = PowerpackBLL._GetFilterXMLByCategory(_GetCategoryID())
            If txtXML.Text = "Not Enabled" Then Me.Visible = False
        End If
    End Sub

    Protected Sub lnkBtnSave_Click(sender As Object, e As EventArgs) Handles lnkBtnSave.Click
        Dim intObjectConfigID As Integer = PowerpackBLL._GetFilterObjectID()
        Dim strMessage As String = String.Empty
        If Not ObjectConfigBLL._SetConfigValue(intObjectConfigID, _GetCategoryID(), txtXML.Text, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            RaiseEvent ShowMasterUpdate()
        End If
    End Sub

    Protected Sub btnGenerate_Click(sender As Object, e As EventArgs) Handles btnGenerate.Click
        txtXML.Text = PowerpackBLL._GenerateFilterXML(_GetCategoryID(), Session("_LANG"))
    End Sub
End Class
