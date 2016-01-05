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

Partial Class Admin_LoginsList

    Inherits _PageBaseClass

    Private Shared intSelectedLoginID As Integer
    Private Shared Login_Protected As Boolean
    Private Shared LOGIN_LanguageID As Integer

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetLocalResourceObject("PageTitle_Logins") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub gvwLogins_RowEditing(ByVal sender As Object, ByVal e As GridViewEditEventArgs) Handles gvwLogins.RowEditing
        hidLoginID.Value = e.NewEditIndex
    End Sub

    Protected Sub gvwLogins_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles gvwLogins.RowDataBound
        ' hide delete button if login is protected
        If e.Row.DataItem IsNot Nothing Then
            Dim LoginRow As DataRowView = CType(e.Row.DataItem, DataRowView)
            Login_Protected = LoginRow("LOGIN_Protected")
            If Login_Protected Then
                DirectCast(e.Row.Cells(9).Controls(0), LinkButton).Visible = False
            End If
        End If
    End Sub

    Private Sub EditLogin(ByVal src As Object, ByVal e As GridViewCommandEventArgs) Handles gvwLogins.RowCommand

        ' get the row index stored in the CommandArgument property 
        Dim intRowIndex As Integer = Convert.ToInt32(e.CommandArgument)

        ' get the GridViewRow where the command is raised 
        Dim rowLogins As GridViewRow = DirectCast(e.CommandSource, GridView).Rows(intRowIndex)

        intSelectedLoginID = CInt(DirectCast(rowLogins.Cells(5).Controls(1), HiddenField).Value)
        Login_Protected = CBool(DirectCast(rowLogins.Cells(6).Controls(1), HiddenField).Value)
        Dim LOGIN_UserName As String = rowLogins.Cells(0).Text

        If e.CommandName = "DeleteLogins" Then
            If Not Login_Protected Then
                Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", LOGIN_UserName)
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
            End If
        Else
            txtPassword.Visible = False
            valRequiredUserPassword.Enabled = False
            lblPassword.Visible = True
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
            btnChangePassword.Visible = True

            Call EnableAll()
            Dim LOGIN_EmailAddress As String = rowLogins.Cells(1).Text
            Dim LOGIN_Password As String = rowLogins.Cells(2).Text
            Dim LOGIN_Config As CheckBox = rowLogins.Cells(3).Controls(1)
            Dim LOGIN_Products As CheckBox = rowLogins.Cells(3).Controls(3)
            Dim LOGIN_Orders As CheckBox = rowLogins.Cells(3).Controls(5)
            Dim LOGIN_Tickets As CheckBox = rowLogins.Cells(3).Controls(7)
            Dim LOGIN_Live As CheckBox = rowLogins.Cells(4).Controls(1)
            Dim LOGIN_PushNotifications = DirectCast(rowLogins.Cells(8).Controls(1), HiddenField).Value

            LOGIN_LanguageID = CInt(DirectCast(rowLogins.Cells(7).Controls(1), HiddenField).Value)


            radNo.Checked = Not LOGIN_Live.Checked
            radYes.Checked = LOGIN_Live.Checked

            chkLoginEditConfig.Checked = LOGIN_Config.Checked
            chkLoginEditProducts.Checked = LOGIN_Products.Checked
            chkLoginEditOrders.Checked = LOGIN_Orders.Checked
            chkLoginEditTickets.Checked = LOGIN_Tickets.Checked

            If Login_Protected Then
                chkLoginEditConfig.Enabled = False
                chkLoginEditOrders.Enabled = False
                chkLoginEditProducts.Enabled = False
                chkLoginEditTickets.Enabled = False
                radYes.Enabled = False
                radNo.Enabled = False
            End If

            txtPassword.Text = LOGIN_Password
            txtUsername.Text = LOGIN_UserName
            txtEmailAddress.Text = LOGIN_EmailAddress
            hidEditPushNotifications.Value = LOGIN_PushNotifications


            Dim xmlDoc As New XmlDocument

            If Not String.IsNullOrEmpty(LOGIN_PushNotifications) Then xmlDoc.LoadXml(LOGIN_PushNotifications)
            BindXMLtoGridView(xmlDoc)

            ddlLanguages.SelectedValue = LOGIN_LanguageID
            lnkNewLogin.Visible = False
            ' hide the gridview
            gvwLogins.Visible = False
        End If

    End Sub

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        If intSelectedLoginID = LoginsBLL.Delete(intSelectedLoginID) Then
            gvwLogins.DataBind()
            updMain.Update()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Kartris", "ContentText_Error"))
        End If

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCancel.Click
        pnlEdit.Visible = False
        lnkNewLogin.Visible = True
        gvwLogins.Visible = True
    End Sub

    Protected Sub lnkNewLogin_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNewLogin.Click
        Call EnableAll()
        lnkNewLogin.Visible = False
        intSelectedLoginID = 0
        Login_Protected = False
        LOGIN_LanguageID = 1

        radNo.Checked = True
        radYes.Checked = False
        chkLoginEditConfig.Checked = False
        chkLoginEditProducts.Checked = False
        chkLoginEditOrders.Checked = False
        chkLoginEditTickets.Checked = False
        btnChangePassword.Visible = False

        txtPassword.Text = ""
        txtEmailAddress.Text = ""
        txtUsername.Text = ""
        ddlLanguages.SelectedValue = LOGIN_LanguageID

        txtPassword.Visible = True
        valRequiredUserPassword.Enabled = True
        lblPassword.Visible = False

        ' hide the gridview
        gvwLogins.Visible = False
    End Sub

    Private Sub EnableAll()
        pnlEdit.Visible = True
        chkLoginEditConfig.Enabled = True
        chkLoginEditOrders.Enabled = True
        chkLoginEditProducts.Enabled = True
        chkLoginEditTickets.Enabled = True
        radYes.Enabled = True
        radNo.Enabled = True
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        If UserNameExist() Then Exit Sub
        Page.Validate("UserDetails")
        If Page.IsValid Then
            If intSelectedLoginID = 0 Then
                LoginsBLL.Add(txtUsername.Text, txtPassword.Text, radYes.Checked, chkLoginEditOrders.Checked, chkLoginEditProducts.Checked,
                              chkLoginEditConfig.Checked, Login_Protected, ddlLanguages.SelectedValue, txtEmailAddress.Text,
                              chkLoginEditTickets.Checked, hidEditPushNotifications.Value)
            ElseIf intSelectedLoginID > 0 Then
                Dim strPassword As String
                If txtPassword.Visible Then strPassword = txtPassword.Text Else strPassword = ""
                LoginsBLL.Update(intSelectedLoginID, txtUsername.Text, strPassword, radYes.Checked, chkLoginEditOrders.Checked,
                                 chkLoginEditProducts.Checked, chkLoginEditConfig.Checked, Login_Protected, ddlLanguages.SelectedValue,
                                 txtEmailAddress.Text, chkLoginEditTickets.Checked, hidEditPushNotifications.Value)
                txtPassword.Visible = False
                valRequiredUserPassword.Enabled = False
                lblPassword.Visible = True
                btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
            End If
            lnkNewLogin.Visible = True
            pnlEdit.Visible = False
            gvwLogins.Visible = True
            lnkNewLogin.Visible = True
            gvwLogins.DataBind()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Function UserNameExist() As Boolean
        For Each row As GridViewRow In gvwLogins.Rows
            If row.RowType = DataControlRowType.DataRow Then
                If intSelectedLoginID <> CInt(DirectCast(row.Cells(5).Controls(1), HiddenField).Value) Then
                    If row.Cells(0).Text.ToLower = txtUsername.Text.ToLower Then
                        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, GetGlobalResourceObject("_Login", "ContentText_UserNameAlreadyExist"))
                        Return True
                    End If
                End If
            End If
        Next
        Return False
    End Function

    Protected Sub btnChangePassword_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtPassword.Visible Then
            txtPassword.Visible = False
            valRequiredUserPassword.Enabled = False
            lblPassword.Visible = True
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "ContentText_ConfigChange2")
        Else
            txtPassword.Visible = True
            valRequiredUserPassword.Enabled = True
            lblPassword.Visible = False
            btnChangePassword.Text = GetGlobalResourceObject("_Kartris", "FormButton_Cancel")
        End If
    End Sub
    Protected Sub lnkNew_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNewDevice.Click
        txtDeviceLabel.Text = ""
        txtDeviceURI.Text = ""
        hidOrigDeviceLabel.Value = ""
        chkDeviceLive.Checked = True
        litContentTextAddEditDevices.Text = GetGlobalResourceObject("_Kartris", "ContentText_AddNew")
        popPushNotification.Show()
    End Sub
    Private Sub EditDevice(ByVal src As Object, ByVal e As GridViewCommandEventArgs) Handles gvwPushNoticationsList.RowCommand

        litContentTextAddEditDevices.Text = GetGlobalResourceObject("_Kartris", "FormButton_Edit")

        ' get the row index stored in the CommandArgument property 
        Dim intRowIndex As Integer = Convert.ToInt32(e.CommandArgument)

        ' get the GridViewRow where the command is raised 
        Dim rowLogins As GridViewRow = DirectCast(e.CommandSource, GridView).Rows(intRowIndex)

        Dim Device_Name As String = rowLogins.Cells(0).Text

            'an existing device - search entry and update XML
            'retrieve push notification XML for this user
            Dim Login_Notifications As String = Trim(hidEditPushNotifications.Value)
            Dim xmlDoc As New XmlDocument
            xmlDoc.LoadXml(Login_Notifications)
            Dim xmlNodeList As XmlNodeList = xmlDoc.GetElementsByTagName("Device")
        For Each node As XmlNode In xmlNodeList
            If node.ChildNodes(0).InnerText = Device_Name Then
                If e.CommandName = "DeleteDevice" Then
                    node.ParentNode.RemoveChild(node)
                    'Bind the new XML data to the push notifications gridview
                    Dim ds As New DataSet()
                    ds.ReadXml(New XmlNodeReader(xmlDoc))
                    hidEditPushNotifications.Value = xmlDoc.OuterXml

                    BindXMLtoGridView(xmlDoc)

                Else
                    hidOrigDeviceLabel.Value = Device_Name
                    txtDeviceLabel.Text = Device_Name
                    txtDeviceURI.Text = node.ChildNodes(2).InnerText
                    chkDeviceLive.Checked = node.ChildNodes(3).InnerText

                    popPushNotification.Show()
                End If
                Exit For
            End If
        Next


    End Sub
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        Page.Validate("PushNotifications")
        If IsValid Then
            'retrieve push notification XML for this user
            Dim Login_Notifications As String = Trim(hidEditPushNotifications.Value)
            Dim xmlDoc As New XmlDocument

            If String.IsNullOrEmpty(Login_Notifications) Then
                'this is first push notification device entry so still need to build up XML

                ' XML declaration
                Dim declaration As XmlNode = xmlDoc.CreateNode(XmlNodeType.XmlDeclaration, Nothing, Nothing)
                xmlDoc.AppendChild(declaration)

                ' Root element: PushNotifications
                Dim root As XmlElement = xmlDoc.CreateElement("PushNotifications")
                xmlDoc.AppendChild(root)

                ' Sub-element: Device
                Dim Device As XmlElement = xmlDoc.CreateElement("Device")

                root.AppendChild(Device)

                SetAllChild(Device, True)
                'doc.Save(Response.OutputStream)
            Else
                'xml structure is already present
                xmlDoc.LoadXml(Login_Notifications)

                If String.IsNullOrEmpty(hidOrigDeviceLabel.Value) Then
                    'new device so just need to add it to the XML
                    Dim root As XmlElement = xmlDoc.DocumentElement
                    ' Sub-element: Device
                    Dim Device As XmlElement = xmlDoc.CreateElement("Device")

                    SetAllChild(Device, True)

                    root.AppendChild(Device)
                Else
                    'an existing device - search entry and update XML
                    Dim xmlNodeList As XmlNodeList = xmlDoc.GetElementsByTagName("Device")
                    For Each node As XmlNode In xmlNodeList
                        If node.ChildNodes(0).InnerText = hidOrigDeviceLabel.Value Then
                            SetAllChild(node, False)
                        End If
                    Next
                End If
            End If

            hidEditPushNotifications.Value = xmlDoc.OuterXml

            BindXMLtoGridView(xmlDoc)
        Else
            popPushNotification.Show()
        End If


    End Sub
    Private Sub BindXMLtoGridView(ByVal xmlDoc As XmlDocument)
        'Bind the XML data to the push notifications gridview
        Dim ds As New DataSet()
        ds.ReadXml(New XmlNodeReader(xmlDoc))
        If ds.Tables.Count > 0 Then
            gvwPushNoticationsList.DataSource = ds.Tables(0)
        Else
            gvwPushNoticationsList.DataSource = Nothing
        End If
        gvwPushNoticationsList.DataBind()
    End Sub
    Private Sub SetAllChild(ByRef DeviceNode As XmlElement, ByVal blnNewNode As Boolean)
        With DeviceNode
            If blnNewNode Then
                ' Sub-element: Name
                Dim DeviceName As XmlElement = .OwnerDocument.CreateElement("Name")
                DeviceName.InnerText = txtDeviceLabel.Text
                .AppendChild(DeviceName)

                ' Sub-element: Platform
                Dim Platform As XmlElement = .OwnerDocument.CreateElement("Platform")
                Platform.InnerText = "devid"
                .AppendChild(Platform)

                ' Sub-element: URI (CDATA)
                Dim URI As XmlElement = .OwnerDocument.CreateElement("URI")
                Dim cdata As XmlNode = .OwnerDocument.CreateCDataSection(txtDeviceURI.Text)
                URI.AppendChild(cdata)
                .AppendChild(URI)

                ' Sub-element: Live ?
                Dim Live As XmlElement = .OwnerDocument.CreateElement("Live")
                Live.InnerText = chkDeviceLive.Checked
                .AppendChild(Live)
            Else
                .ChildNodes(0).InnerText = txtDeviceLabel.Text
                .ChildNodes(1).InnerText = "devid"
                .ChildNodes(2).InnerText = txtDeviceURI.Text
                .ChildNodes(3).InnerText = chkDeviceLive.Checked
            End If
        End With
        
    End Sub
End Class
