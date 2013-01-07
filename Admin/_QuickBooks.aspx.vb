
Partial Class Admin_QuickBooks
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_QuickBooks", "PageTitle_QBIntegration") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        ''********************************* License Code ****************************************************
        '' This code checks the license validity. If you remove this, it won't disable or bypass the license
        ''  functionality, but it will prevent you seeing clear errors or warnings relating to the license.
        ''  License issues will still be added to the error logs.
        'If LCase(LicenseChecker.GetLicenseFeatureSet) = "free" OrElse LCase(LicenseChecker.GetLicenseFeatureSet) = "limited" Then
        '    'This is free version, disable live currency update page
        '    phdMainContent.Visible = False
        '    litMessage.Text = Kartris.LicenseChecker.FreeVersionDisabledTag
        '    litMessage.Visible = True
        'Else
        'Reset page elements visibility
        phdMainContent.Visible = True
        litMessage.Visible = False

        'Run normal functionality
        If Not IsPostBack Then
            txtQBWCPassword.Text = KartSettingsManager.GetKartConfig("general.quickbooks.pass")
            txtQBWCPassword.Attributes("value") = txtQBWCPassword.Text

            lblFormLabelPassword.Text = "QBWC " & GetGlobalResourceObject("_Kartris", "FormLabel_Password")
        End If
        'End If
        ''************************************ End of License Code ***************************************
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Dim strPass As String = txtQBWCPassword.Text
        If Not String.IsNullOrEmpty(strPass) Then
            If strPass <> KartSettingsManager.GetKartConfig("general.quickbooks.pass") Then
                txtQBWCPassword.Attributes("value") = strPass
                KartSettingsManager.SetKartConfig("general.quickbooks.pass", UsersBLL.EncryptSHA256Managed(txtQBWCPassword.Text, "quickbooks", True))
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
            End If
        End If
    End Sub

    Protected Sub btnGenerate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnGenerate.Click
        If String.IsNullOrEmpty(txtQBWCPassword.Text) Then
            txtQBWCPassword.Text = KartSettingsManager.GetKartConfig("general.quickbooks.pass")
        End If
        If String.IsNullOrEmpty(KartSettingsManager.GetKartConfig("general.quickbooks.pass")) Then txtQBWCPassword.Text = ""
        Page.Validate()
        If IsValid Then
            Dim _xmlDoc As New XmlDocument()
            _xmlDoc.Load(Path.Combine(Request.PhysicalApplicationPath, "Uploads\resources\KartrisQuickBooks.qwc"))

            Dim _xmlNode As XmlNode = _xmlDoc.DocumentElement
            Dim _xmlNodeList As XmlNodeList = _xmlNode.SelectNodes("/QBWCXML")

            For x As Integer = 0 To _xmlNodeList.Count - 1
                For Each Node As XmlNode In _xmlNodeList.Item(x).ChildNodes
                    '' check if the current node is the specified parent element
                    If Node.Name = "AppURL" Then
                        Node.InnerText = CkartrisBLL.WebShopURL & "KartrisQBService.asmx"
                    ElseIf Node.Name = "Scheduler" Then
                        For Each innerNode As XmlNode In Node.ChildNodes
                            '' check if the current inner node is the element we want
                            If innerNode.Name = "RunEveryNMinutes" Then innerNode.InnerText = txtInterval.Text
                        Next
                    ElseIf Node.Name = "FileID" Then
                        Node.InnerText = "{" & System.Guid.NewGuid.ToString & "}"
                    End If
                Next
            Next

            Try
                Response.ContentType = "text/plain"
                Response.AppendHeader("Content-Disposition", "attachment; filename=KartrisQuickBooks.qwc")
                _xmlDoc.Save(Response.OutputStream)
                Response.End()
            Catch eEx As Exception
                'litReason.Text = "<p>" & eEx.Message & "</p>"
            End Try
        End If
    End Sub




End Class
