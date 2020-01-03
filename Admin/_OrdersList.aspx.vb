'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_OrdersList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetLocalResourceObject("PageTitle_Orders") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        Dim CallMode As OrdersBLL.ORDERS_LIST_CALLMODE
        If Not Page.IsPostBack Then
            If Trim(Request.QueryString("CallMode")) <> "" Then
                Try
                    'Read the query string and see if it's one of the Order list's Callmode
                    Dim strCallMode As String = Request.QueryString("CallMode")

                    CallMode = System.Enum.Parse(GetType(OrdersBLL.ORDERS_LIST_CALLMODE), UCase(strCallMode))

                    'Set the Page Title and Description text for the Callmode
                    ProcessCallMode(CallMode)
                Catch ex As Exception
                    'Display in recent mode if the Querystring is invalid
                    CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.RECENT
                End Try
            Else
                CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.RECENT
            End If
        End If
        txtSearch.Focus()
    End Sub

    Private Sub ProcessCallMode(ByVal CallMode As OrdersBLL.ORDERS_LIST_CALLMODE)
        Dim strCallMode = StrConv(System.Enum.GetName(GetType(OrdersBLL.ORDERS_LIST_CALLMODE), CallMode), VbStrConv.ProperCase)
        If LCase(strCallMode) = "bybatch" Then
            litOrderListMode.Text = GetLocalResourceObject("PageTitle_BatchProcess")
            litModeDetails.Text = GetLocalResourceObject("ContentText_BatchProcessText")
        ElseIf LCase(strCallMode) = "customer" Then
            litOrderListMode.Text = GetLocalResourceObject("PageTitle_OrdersCustomerEmail")
            litModeDetails.Text = GetLocalResourceObject("ContentText_OrdersEmailText")
            _UC_OrdersList.datValue2 = Request.QueryString("CustomerID")
        Else
            litOrderListMode.Text = GetLocalResourceObject("PageTitle_Orders" & strCallMode)
            litModeDetails.Text = GetLocalResourceObject("ContentText_Orders" & strCallMode & "Text")
        End If

        If CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.GATEWAY Then
            litEnterDate.Text = GetLocalResourceObject("ContentText_SelectGateWay")
            lblFindOrder.Text = GetLocalResourceObject("ContextText_TransID")
            phdGateway.Visible = True
            btnCalendar.Visible = False
            calDateSearch.Enabled = False
            If ddlGateways.Items.Count > 0 Then
                If ddlGateways.Items(0).Value <> "All Payment Gateways" Then ddlGateways.Items.Insert(0, "All Payment Gateways")
            Else
                ddlGateways.Items.Insert(0, "All Payment Gateways")
            End If
        ElseIf CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.BYBATCH Then
            pnlSearch.Visible = False
            _UC_OrdersList.BatchProcess = True
            CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
        End If
        _UC_OrdersList.CallMode = CallMode
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSearch.Click

        'Handle search for order number
        'Don't check we find one, quicker
        'this way.
        If IsNumeric(txtSearch.Text) Then
            'Search by Order ID
            Dim intOrderID As Integer = CInt(txtSearch.Text)
            Response.Redirect("_ModifyOrderStatus.aspx?OrderID=" & intOrderID)
        End If

        'Reset the order list's pager control
        _UC_OrdersList.ResetCurrentPage()
        If Trim(Request.QueryString("CallMode")) = LCase("gateway") Then
            ProcessCallMode(OrdersBLL.ORDERS_LIST_CALLMODE.GATEWAY)
            _UC_OrdersList.datValue1 = ddlGateways.SelectedValue
            _UC_OrdersList.datValue2 = txtSearch.Text
            _UC_OrdersList.RefreshOrdersList()
        Else
            'Check the search box and decide what type of
            'search this is
            If Trim(txtSearch.Text) = "" Then
                'blank - do nothing
            ElseIf IsDate(txtSearch.Text) Then
                'Date search
                _UC_OrdersList.datValue1 = txtSearch.Text
                ProcessCallMode(OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE)
                _UC_OrdersList.RefreshOrdersList()
                If IsDate(_UC_OrdersList.datValue1) And _UC_OrdersList.datValue1 <> Date.MinValue Then txtSearch.Text = _UC_OrdersList.datValue1
            Else
                'Text search
                _UC_OrdersList.datValue2 = txtSearch.Text
                ProcessCallMode(OrdersBLL.ORDERS_LIST_CALLMODE.SEARCH)
                _UC_OrdersList.RefreshOrdersList()
            End If
        End If

    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_OrdersList.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub
End Class
