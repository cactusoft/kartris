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
Partial Class Admin_CustomersList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetLocalResourceObject("PageTitle_Customers") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        txtSearch.Focus()
        If Not Page.IsPostBack Then
            txtSearch.Attributes.Add("onkeydown", "if(event.which || event.keyCode){if ((event.which == 13) || (event.keyCode == 13)) {document.getElementById('" + btnSearch.ClientID + "').click();return false;}} else {return true}; ")
        End If

        Dim strMode As String = Request.QueryString("mode")

        If Trim(strMode) <> "" Then
            If strMode = "af" Then
                _UC_CustomersList.isAffiliates = True
                If Trim(Request.QueryString("approve")) = "y" Then
                    _UC_CustomersList.isApproved = True
                End If
                litCustomersListTitle.Text = GetLocalResourceObject("PageTitle_Customers") & ": <span class=""h1_light"">" & GetGlobalResourceObject("_Customers", "PageTitle_Affiliates") & "</span>"
            ElseIf strMode = "ml" Then
                _UC_CustomersList.isMailingList = True
                litCustomersListTitle.Text = GetLocalResourceObject("PageTitle_Customers") & ": <span class=""h1_light"">" & GetGlobalResourceObject("_Customers", "PageTitle_MailingList") & "</span>"
            End If
        ElseIf Request.QueryString("cg") <> "" Then
            If IsNumeric(Request.QueryString("cg")) Then
                _UC_CustomersList.CustomerGroupID = CInt(Request.QueryString("cg"))
                Dim strCustomerGroupName As String = GetGlobalResourceObject("_Customers", "PageTitle_CustomerGroups")
                Try
                    Dim drwCustomerGroup As DataRow() =
                                KartSettingsManager.GetCustomerGroupsFromCache.Select("CG_ID=" &
                                _UC_CustomersList.CustomerGroupID &
                                " AND LANG_ID=" & CkartrisBLL.GetLanguageIDfromSession("b"))
                    If drwCustomerGroup.Length <> 0 Then
                        strCustomerGroupName = drwCustomerGroup(0)("CG_Name").ToString()
                    End If
                Catch ex As Exception
                    'Can't retrieve customer group name, do nothing
                End Try
                litCustomersListTitle.Text = GetLocalResourceObject("PageTitle_Customers") & ": <span class=""h1_light"">" & strCustomerGroupName & "</span>"
            End If
        End If


        'Pre-fill search box if we're coming back from
        'a customer and sending back the search term
        If Not Page.IsPostBack Then
            txtSearch.Text = Request.QueryString("strSearch")
            Call RunSearch()
        End If

    End Sub

    'Handles search button clicked
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click
        _UC_CustomersList.ResetCurrentPage()
        Call RunSearch()
    End Sub

    'This actually runs the search; we can use this
    'from the search button, or if the page loads
    'with some values passed in via querystring
    Protected Sub RunSearch()
        If IsNumeric(txtSearch.Text) Then
            If DirectCast(UsersBLL._GetCustomerDetails(txtSearch.Text), DataTable).Rows.Count > 0 Then
                Response.Redirect("_ModifyCustomerStatus.aspx?CustomerID=" & txtSearch.Text)
            Else
                _UC_CustomersList.strSearch = txtSearch.Text
                _UC_CustomersList.RefreshCustomersList()
            End If
        Else
            _UC_CustomersList.strSearch = txtSearch.Text
            _UC_CustomersList.RefreshCustomersList()
        End If
    End Sub
End Class
