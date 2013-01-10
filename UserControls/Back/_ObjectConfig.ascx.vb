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
Imports CkartrisDataManipulation
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisImages
Imports KartSettingsManager

Partial Class UserControls_Back_ObjectConfig
    Inherits System.Web.UI.UserControl

    Private _ItemType As String

    Public WriteOnly Property ItemType() As String
        Set(ByVal value As String)
            _ItemType = value
        End Set
    End Property

    Private _ItemID As Long

    Public WriteOnly Property ItemID() As Long
        Set(ByVal value As Long)
            _ItemID = value
        End Set
    End Property

    Public Event ShowMasterUpdate()

    Public Sub LoadObjectConfig()
        Dim dtbObjectConfig As DataTable = ObjectConfigBLL._GetData()
        Dim dvwObjectConfig As DataView = dtbObjectConfig.DefaultView
        dvwObjectConfig.RowFilter = "OC_ObjectType = '" & _ItemType & "'"
        rptObjectConfig.DataSource = dvwObjectConfig
        rptObjectConfig.DataBind()
    End Sub

    Protected Sub ConfigSelected(ByVal sender As Object, ByVal e As EventArgs)
        For Each itmObjectConfig As RepeaterItem In rptObjectConfig.Items
            If itmObjectConfig.ItemType = ListItemType.AlternatingItem OrElse ListItemType.Item Then
                If CType(itmObjectConfig.FindControl("chkSelect"), CheckBox).ClientID = CType(sender, CheckBox).ClientID Then
                    CType(itmObjectConfig.FindControl("phdConfigDetails"), PlaceHolder).Visible = CType(sender, CheckBox).Checked
                End If
            End If
        Next
    End Sub

    Protected Sub rptObjectConfig_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptObjectConfig.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then
            Dim strConfigName As String = CType(e.Item.FindControl("litConfigName"), Literal).Text
            Dim objConfigValue As Object = ObjectConfigBLL._GetValue(strConfigName, _ItemID)
            If objConfigValue IsNot Nothing Then
                If CType(e.Item.FindControl("litConfigType"), Literal).Text = "b" Then
                    CType(e.Item.FindControl("chkSelected"), CheckBox).Checked = CBool(objConfigValue)
                Else
                    CType(e.Item.FindControl("txtValue"), TextBox).Text = CStr(objConfigValue)
                    If CType(e.Item.FindControl("chk_HiddenMultiline"), CheckBox).Checked Then
                        CType(e.Item.FindControl("txtValue"), TextBox).TextMode = TextBoxMode.MultiLine
                        CType(e.Item.FindControl("txtValue"), TextBox).MaxLength = 4000
                    End If
                End If
            End If
        End If
    End Sub

    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSave.Click
        SaveConfig()
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        LoadObjectConfig()
    End Sub

    Sub SaveConfig()
        Dim blnHasErrors As Boolean = False
        For Each itmObjectConfig As RepeaterItem In rptObjectConfig.Items
            If itmObjectConfig.ItemType = ListItemType.Item OrElse itmObjectConfig.ItemType = ListItemType.AlternatingItem Then
                Dim numConfigID As Integer = CInt(CType(itmObjectConfig.FindControl("litConfigID"), Literal).Text)
                Dim strConfigType As String = CType(itmObjectConfig.FindControl("litConfigType"), Literal).Text
                Dim strValue As String = Nothing
                Dim strMessage As String = Nothing
                If strConfigType = "b" Then
                    strValue = IIf(CType(itmObjectConfig.FindControl("chkSelected"), CheckBox).Checked, "1", "0")
                Else
                    strValue = CType(itmObjectConfig.FindControl("txtValue"), TextBox).Text
                End If
                'If String.IsNullOrEmpty(strValue) Then Continue For
                If Not ObjectConfigBLL._SetConfigValue(numConfigID, _ItemID, strValue, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    blnHasErrors = True
                    Exit For
                End If
            End If
        Next
        If Not blnHasErrors Then
            RaiseEvent ShowMasterUpdate()
            LoadObjectConfig()
        End If
    End Sub
End Class
