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
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager
Partial Class UserControls_Back_OrdersList
    Inherits System.Web.UI.UserControl

    Private _RowCount As Integer

    Private blnTableCopied As Boolean = False
    Private tblOriginal As DataTable

    ''' <summary>
    ''' this runs when an update to data is made to trigger the animation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Culture = System.Globalization.CultureInfo.CreateSpecificCulture(System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName).Name
        If Not IsPostBack Then
            RefreshOrdersList()
            GoToCorrectPage()
        End If
    End Sub

    ''' <summary>
    ''' Order List Call Mode. See ORDERS_LIST_CALLMODE Enum in OrdersBLL to check the available call modes.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property CallMode() As OrdersBLL.ORDERS_LIST_CALLMODE
        Get
            Return ViewState("_Callmode")
        End Get
        Set(ByVal value As OrdersBLL.ORDERS_LIST_CALLMODE)
            ViewState("_Callmode") = value
        End Set
    End Property

    ''' <summary>
    ''' Activate / Deactivate Order List Batch Process Mode. 
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property BatchProcess() As Boolean
        Get
            Return ViewState("_BatchProcess")
        End Get
        Set(ByVal value As Boolean)
            ViewState("_BatchProcess") = value
        End Set
    End Property

    Public ReadOnly Property RowCount() As Integer
        Get
            Return _RowCount
        End Get
    End Property

    ''' <summary>
    ''' A generic parameter. Expects either the Affiliate ID, Payment Gateway Code, or the Date depending on the callmode.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property datValue1() As String
        Get
            Return ViewState("_datValue1")
        End Get
        Set(ByVal value As String)
            ViewState("_datValue1") = value
        End Set
    End Property

    ''' <summary>
    ''' A generic parameter. Expects the Gateway Reference Code but will also accept the second Date value in case we decide to search the orders by date range.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property datValue2() As String
        Get
            Return ViewState("_datValue2")
        End Get
        Set(ByVal value As String)
            ViewState("_datValue2") = value
        End Set
    End Property

    Public Sub RefreshOrdersList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        If ViewState("intTotalRowCount") Is Nothing Then blnRetrieveTotalCount = True
        'If the callmode if 'ByDate' then we need to convert the parameters to 'Date'
        Dim tblOrdersList As DataTable = Nothing

        Dim intRowsPerPage As Integer = 25
        Try
            intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
        Catch ex As Exception
            'Stays at 25
        End Try

        'See if date passed to page by querystring
        Dim strDateQS As String = Request.QueryString("strDate")

        'If date passed by querystring, set up page
        If IsDate(strDateQS) And Not Me.IsPostBack Then
            ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
            ViewState("_datValue1") = strDateQS
            ViewState("_datValue2") = Date.MinValue
        End If

        'backend.search.pagesize
        Dim intCurrentPage As Integer = _UC_ItemPager.CurrentPage
        If ViewState("_BatchProcess") Then ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
        If ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE Then

            If Trim(ViewState("_datValue2")) = "" Then ViewState("_datValue2") = Date.MinValue
            If Trim(ViewState("_datValue1")) = "" Or Not IsDate(ViewState("_datValue1")) Then
                ViewState("_datValue1") = Today
            End If

            'Dim datValue As Date = Format(CDate(ViewState("_datValue1")), "d MMM yy")
            Dim datValue As Date
            Try
                datValue = CkartrisDisplayFunctions.FormatDate(CDate(ViewState("_datValue1")), "d", Session("_LANG"))
            Catch ex As Exception
                datValue = "01/01/2001"
            End Try

            tblOrdersList = OrdersBLL._GetByStatus(ViewState("_Callmode"), intCurrentPage, 0, datValue, CDate(ViewState("_datValue2")), "", "", intRowsPerPage)
            ViewState("intTotalRowCount") = OrdersBLL._GetByStatusCount(ViewState("_Callmode"), 0, datValue, CDate(ViewState("_datValue2")), "", "")

            If datValue = "01/01/2001" Then
                datValue = Today
                btnTomorrow.Visible = False
            Else
                btnTomorrow.Visible = True
            End If

            phdDateNavigation.Visible = True

            btnTomorrow.Text = CkartrisDisplayFunctions.FormatDate(datValue.AddDays(1), "d", Session("_LANG"))

            If datValue.AddDays(1) > Now.Date Then btnTomorrow.Enabled = False Else btnTomorrow.Enabled = True

            btnYesterday.Text = CkartrisDisplayFunctions.FormatDate(datValue.AddDays(-1), "d", Session("_LANG"))

            litToday.Text = CkartrisDisplayFunctions.FormatDate(datValue, "d", Session("_LANG"))
            litSelectedLongDate.Text = datValue.ToLongDateString

        Else
            If ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.UNFINISHED Then
                phdPurgeOrder.Visible = True
                If Not IsPostBack Then btnPurgeOrders.Text += CkartrisDisplayFunctions.FormatDate(Today.AddDays(-CInt(GetKartConfig("backend.orders.unfinished.purgedays"))), "d", Session("_LANG"))
            End If

            phdDateNavigation.Visible = False
            Dim intAffID As Integer = 0
            If IsNumeric(ViewState("_datValue1")) Then intAffID = CInt(ViewState("_datValue1"))
            tblOrdersList = OrdersBLL._GetByStatus(ViewState("_Callmode"), intCurrentPage, intAffID, , , ViewState("_datValue1"), ViewState("_datValue2"), intRowsPerPage)
            If blnRetrieveTotalCount Then ViewState("intTotalRowCount") = OrdersBLL._GetByStatusCount(ViewState("_Callmode"), intAffID, , , ViewState("_datValue1"), ViewState("_datValue2"))
        End If
        _RowCount = tblOrdersList.Rows.Count

        If _RowCount = 0 Then
            litOLIndicates.Text = GetLocalResourceObject("ContentText_NoOrdersMadeOnThisDay")
            litOLIndicatesComplete.Text = ""
        Else
            litOLIndicates.Text = GetLocalResourceObject("ContentText_OrdersListIndicates")
            litOLIndicatesComplete.Text = GetLocalResourceObject("ContentText_OrdersListIndicatesComplete")
        End If

        If ViewState("_BatchProcess") Then
            litOLIndicatesComplete.Visible = False
            If tblOrdersList.Rows.Count > 0 Then
                litOLIndicates.Visible = False
                phdBatchProcessButtons.Visible = True
            Else
                litOLIndicates.Visible = True
                phdBatchProcessButtons.Visible = False
            End If
        End If

        If Not blnTableCopied Then
            ViewState("originalValuesDataTable") = tblOrdersList
            blnTableCopied = True
        End If
        _UC_ItemPager.TotalItems = ViewState("intTotalRowCount")
        _UC_ItemPager.ItemsPerPage = intRowsPerPage
        _UC_ItemPager.PopulatePagerControl()
        gvwOrders.DataSource = tblOrdersList
        gvwOrders.DataBind()

        If litOLIndicatesComplete.Visible = False And litOLIndicates.Visible = False Then
            phdIndicates.Visible = False
        Else
            phdIndicates.Visible = True
        End If
    End Sub

    'When we click through to an order, we tag
    'whether we were viewing orders by date. If
    'so, we want the 'back' link to pass the date
    'back so we can continue to view the same date.
    Public Function TagIfReturnToDate() As String
        If litToday.Text = "" Then
            'Not a date one
            Return "false"
        Else
            Return "true"
        End If
    End Function

    'When we click through to an order, we tag
    'the link with the current page in the gridview.
    'This way, if you click through from the second
    'page, the back link can send this info back so
    'you click back to the same page in the results.
    Public Function CurrentPageNumber() As String
        'Add 1 because it's easier if number passed
        'matches the page number link
        Return _UC_ItemPager.CurrentPage.ToString + 1
    End Function

    Public Sub ResetCurrentPage()
        _UC_ItemPager.CurrentPage = 0
    End Sub

    'If we have paging of results, this will
    'go to correct page when returning from
    'editing or viewing an order
    Public Sub GoToCorrectPage()
        If Request.QueryString("Page") <> "" Then
            Try
                Dim numPage As Integer = 0
                numPage = Request.QueryString("Page")
                _UC_ItemPager.CurrentPage = numPage - 1
                RefreshOrdersList(False)
            Catch ex As Exception
                'Fail
            End Try
        End If
    End Sub

    Protected Sub PageChanged() Handles _UC_ItemPager.PageChanged
        RefreshOrdersList(False)
    End Sub

    Private Sub gvwOrders_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwOrders.RowDataBound
        If e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Header And e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Footer Then
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim litOrderValue As Literal = DirectCast(e.Row.FindControl("litOrderValue"), Literal)
                Dim hidOrderCurrencyID As HiddenField = DirectCast(e.Row.FindControl("hidOrderCurrencyID"), HiddenField)
                Dim hidOrderChildID As HiddenField = DirectCast(e.Row.FindControl("hidOrderChildID"), HiddenField)

                Dim numOrderValue As Single = CSng(litOrderValue.Text)
                Dim srtOrderCurrencyID As Short = CShort(hidOrderCurrencyID.Value)

                'Format the Order Total Price base on the Gateway's Currency
                Try
                    litOrderValue.Text = CurrenciesBLL.FormatCurrencyPrice(srtOrderCurrencyID, numOrderValue)
                Catch ex As Exception
                    litOrderValue.Text = "? " & numOrderValue
                End Try


                If ViewState("_BatchProcess") Then
                    Dim phdBatchProcess As PlaceHolder = DirectCast(e.Row.FindControl("phdBatchProcess"), PlaceHolder)
                    Dim hidOrderID As HiddenField = DirectCast(e.Row.FindControl("hidOrderID"), HiddenField)
                    phdBatchProcess.Visible = True
                Else
                    Dim chkOrderSent As CheckBox = DirectCast(e.Row.FindControl("chkOrderSent"), CheckBox)
                    Dim chkOrderPaid As CheckBox = DirectCast(e.Row.FindControl("chkOrderPaid"), CheckBox)
                    Dim chkOrderInvoiced As CheckBox = DirectCast(e.Row.FindControl("chkOrderInvoiced"), CheckBox)
                    Dim chkOrderShipped As CheckBox = DirectCast(e.Row.FindControl("chkOrderShipped"), CheckBox)
                    Dim litOrderDate As Literal = DirectCast(e.Row.FindControl("litOrderDate"), Literal)

                    Dim chkOrderCancelled As CheckBox = DirectCast(e.Row.FindControl("chkOrderCancelled"), CheckBox)

                    Dim datOrderDate As Date = CType(litOrderDate.Text, Date)

                    'This block changes the row style based on the Order Status
                    If chkOrderPaid.Checked Then
                        If chkOrderShipped.Checked Then
                            e.Row.CssClass = "Done"
                        Else
                            e.Row.CssClass = "Green"
                        End If
                    Else
                        'Add the 'invoiceduedays' config setting to the current date to know if we should mark the order as 'awaiting payment'
                        If chkOrderInvoiced.Checked And _
                            (datOrderDate.AddDays(CType(KartSettingsManager.GetKartConfig("backend.orders.invoiceduedays"), Double)) < Now) Then
                            e.Row.CssClass = "Red"
                        End If
                    End If

                    'If this order has been cancelled and callmode is 'cancelled, use Violet otherwise hide row
                    If chkOrderCancelled.Checked Then
                        If CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.CANCELLED Then
                            e.Row.CssClass = "Violet"
                        Else
                            e.Row.Cells.Clear()
                            e.Row.Visible = False
                        End If

                    End If

                    'append the correct prefix base on the rowstate - this just makes the code neater
                    If e.Row.CssClass <> "" Then
                        If e.Row.RowState = DataControlRowState.Alternate Then
                            e.Row.CssClass = "Kartris-GridView-Alternate-" & e.Row.CssClass
                        Else
                            e.Row.CssClass = "Kartris-GridView-" & e.Row.CssClass
                        End If
                    End If
                End If

            End If
        End If
    End Sub

    Protected Sub btnDates_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnTomorrow.Click, btnYesterday.Click
        Dim btnThis As LinkButton = DirectCast(sender, LinkButton)
        ViewState("_datValue1") = btnThis.Text
        ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
        gvwOrders.PageIndex = 0
        RefreshOrdersList()
    End Sub
    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs) Handles btnSearch.Click
        ViewState("_datValue1") = txtFilterDate.Text
        ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE
        gvwOrders.PageIndex = 0
        RefreshOrdersList()
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        tblOriginal = DirectCast(ViewState("originalValuesDataTable"), DataTable)

        For Each r As GridViewRow In gvwOrders.Rows
            If IsRowModified(r) Then
                gvwOrders.UpdateRow(r.RowIndex, False)
            End If
        Next

        'Rebind the Grid to repopulate the original values table.
        blnTableCopied = False
        RefreshOrdersList()
        RaiseEvent ShowMasterUpdate()

    End Sub

    Protected Function IsRowModified(ByVal r As GridViewRow) As Boolean
        Dim currentID As Integer = Convert.ToInt32(gvwOrders.DataKeys(r.RowIndex).Value)
        Dim rowOrders As DataRow = tblOriginal.Select(String.Format("O_ID = {0}", currentID))(0)

        Dim chkOrderPaid As CheckBox = DirectCast(r.FindControl("chkOrderPaid"), CheckBox)
        Dim chkOrderInvoiced As CheckBox = DirectCast(r.FindControl("chkOrderInvoiced"), CheckBox)
        Dim chkOrderShipped As CheckBox = DirectCast(r.FindControl("chkOrderShipped"), CheckBox)
        Dim chkOrderCancelled As CheckBox = DirectCast(r.FindControl("chkOrderCancelled"), CheckBox)


        If Not chkOrderPaid.Checked = rowOrders("O_Paid") Then Return True
        If Not chkOrderInvoiced.Checked = rowOrders("O_Invoiced") Then Return True
        If Not chkOrderShipped.Checked = rowOrders("O_Shipped") Then Return True
        If Not chkOrderCancelled.Checked = rowOrders("O_Cancelled") Then Return True

        Return False
    End Function

    Protected Sub gvwOrders_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs) Handles gvwOrders.RowUpdating
        Dim intCurrentID As Integer = Convert.ToInt32(gvwOrders.DataKeys(e.RowIndex).Value)
        Dim rowOrders As DataRow = tblOriginal.Select(String.Format("O_ID = {0}", intCurrentID))(0)
        Dim rowGridView As GridViewRow = gvwOrders.Rows(e.RowIndex)

        Dim chkOrderPaid As CheckBox = DirectCast(rowGridView.FindControl("chkOrderPaid"), CheckBox)
        Dim chkOrderInvoiced As CheckBox = DirectCast(rowGridView.FindControl("chkOrderInvoiced"), CheckBox)
        Dim chkOrderShipped As CheckBox = DirectCast(rowGridView.FindControl("chkOrderShipped"), CheckBox)
        Dim hidOrderID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderID"), HiddenField)
        Dim hidOrderStatus As HiddenField = DirectCast(rowGridView.FindControl("hidOrderStatus"), HiddenField)
        Dim chkOrderCancelled As CheckBox = DirectCast(rowGridView.FindControl("chkOrderCancelled"), CheckBox)

        OrdersBLL._UpdateStatus(hidOrderID.Value, True, chkOrderPaid.Checked, chkOrderShipped.Checked, chkOrderInvoiced.Checked, hidOrderStatus.Value, "", chkOrderCancelled.Checked)
        
        'Email order update?
        If chkInformCustomers.Checked Then
            Dim hidOrderLanguageID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderLanguageID"), HiddenField)
            Dim hidCustomerID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderCustomerID"), HiddenField)

            Dim strCustomOrderStatus As String = String.Empty
            If chkOrderShipped.Checked Then
                strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusShipped") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
            ElseIf chkOrderPaid.Checked Then
                strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusPaid") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
            ElseIf chkOrderInvoiced.Checked Then
                strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusInvoiced") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
            ElseIf chkOrderCancelled.Checked Then
                strCustomOrderStatus = GetGlobalResourceObject("_Orders", "ContentText_OrderStatusCancelled") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
            Else
                strCustomOrderStatus = hidOrderStatus.Value
            End If
            Dim strEmailFrom As String = LanguagesBLL.GetEmailFrom(CInt(hidOrderLanguageID.Value))
            Dim strEmailTo As String = UsersBLL.GetEmailByID(CInt(hidCustomerID.Value))
            Dim strEmailText As String
            Dim strSubjectLine As String = GetGlobalResourceObject("Email", "EmailText_OrderUpdateFrom") & " " & GetGlobalResourceObject("Kartris", "Config_Webshopname")
            strEmailText = GetGlobalResourceObject("Email", "EmailText_OrderStatusUpdated").Replace("[order_status]", strCustomOrderStatus) & vbCrLf & vbCrLf & WebShopURL() & "CustomerViewOrder.aspx?O_ID=" & intCurrentID
            SendEmail(strEmailFrom, strEmailTo, strSubjectLine, strEmailText)
        End If

    End Sub

    Protected Sub btnPurgeOrders_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnPurgeOrders.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
        RefreshOrdersList()
    End Sub

    ''' <summary>
    ''' if the delete is confirmed, "Yes" is chosen
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        OrdersBLL._PurgeOrders(Today.AddDays(-CInt(GetKartConfig("backend.orders.unfinished.purgedays"))))
        Response.Redirect("_OrdersList.aspx?callmode=unfinished")
    End Sub


    
End Class
