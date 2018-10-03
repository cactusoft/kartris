'========================================================================
'Kartris - www.kartris.com
'Copyright 2018 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'
'Modification by Craig Moore - Deadline Automation Limited
'2014-11-20 - Add calls to custom control _DispatchLabels.ascx for the 
'purpose of printing labels through PDFSharp
'========================================================================
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager
Partial Class UserControls_Back_SubSiteList
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
            RefreshSubSiteList()
            'If CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.DISPATCH Then
            '    DispatchLabels.Visible = True
            'End If
        End If

        ' Prevents the button triggering a partial postback as in some browsers that postback never
        ' completes when using the response.redirect function
        'Dim PrintLabelButton As Button = CType(DispatchLabels.FindControl("btnPrint"), Button)
        'ScriptManager.GetCurrent(Page).RegisterPostBackControl(PrintLabelButton)

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

    Public Sub RefreshSubSiteList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        If ViewState("intTotalRowCount") Is Nothing Then blnRetrieveTotalCount = True
        'If the callmode if 'ByDate' then we need to convert the parameters to 'Date'
        Dim tblSubSitesList As DataTable = Nothing

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
        If ViewState("_BatchProcess") Then ViewState("_Callmode") = OrdersBLL.ORDERS_LIST_CALLMODE.BYDATE

        tblSubSitesList = SubSitesBLL.GetSubSites()

        _RowCount = tblSubSitesList.Rows.Count



        If Not blnTableCopied Then
            ViewState("originalValuesDataTable") = tblSubSitesList
            blnTableCopied = True
        End If
        '_UC_ItemPager.TotalItems = ViewState("intTotalRowCount")
        '_UC_ItemPager.ItemsPerPage = intRowsPerPage
        '_UC_ItemPager.PopulatePagerControl()
        gvwSubSites.DataSource = tblSubSitesList
        gvwSubSites.DataBind()

        'If litOLIndicatesComplete.Visible = False And litOLIndicates.Visible = False Then
        '    phdIndicates.Visible = False
        'Else
        '    phdIndicates.Visible = True
        'End If
    End Sub

    'Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
    '    Dim tblOriginal As DataTable = DirectCast(ViewState("originalValuesDataTable"), DataTable)
    '    For Each rowOrder As GridViewRow In gvwOrders.Rows
    '        If IsRowModified(rowOrder) Then
    '            gvwOrders.UpdateRow(rowOrder.RowIndex, False)
    '        End If
    '    Next

    '    'Rebind the Grid to repopulate the original values table.
    '    blnTableCopied = False
    '    RefreshSubSiteList()
    '    RaiseEvent ShowMasterUpdate()
    'End Sub


    'Protected Function IsRowModified(ByVal r As GridViewRow) As Boolean
    '    Dim currentID As Integer = Convert.ToInt32(gvwOrders.DataKeys(r.RowIndex).Value)
    '    Dim rowOrders As DataRow = tblOriginal.Select(String.Format("O_ID = {0}", currentID))(0)

    '    Dim chkOrderPaid As CheckBox = DirectCast(r.FindControl("chkOrderPaid"), CheckBox)
    '    Dim chkOrderInvoiced As CheckBox = DirectCast(r.FindControl("chkOrderInvoiced"), CheckBox)
    '    Dim chkOrderShipped As CheckBox = DirectCast(r.FindControl("chkOrderShipped"), CheckBox)
    '    Dim chkOrderCancelled As CheckBox = DirectCast(r.FindControl("chkOrderCancelled"), CheckBox)


    '    If Not chkOrderPaid.Checked = rowOrders("O_Paid") Then Return True
    '    If Not chkOrderInvoiced.Checked = rowOrders("O_Invoiced") Then Return True
    '    If Not chkOrderShipped.Checked = rowOrders("O_Shipped") Then Return True
    '    If Not chkOrderCancelled.Checked = rowOrders("O_Cancelled") Then Return True

    '    Return False
    'End Function

    'Protected Sub gvwOrders_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs) Handles gvwOrders.RowUpdating
    '    Dim intCurrentID As Integer = Convert.ToInt32(gvwOrders.DataKeys(e.RowIndex).Value)
    '    Dim rowOrders As DataRow = tblOriginal.Select(String.Format("O_ID = {0}", intCurrentID))(0)
    '    Dim rowGridView As GridViewRow = gvwOrders.Rows(e.RowIndex)

    '    Dim chkOrderPaid As CheckBox = DirectCast(rowGridView.FindControl("chkOrderPaid"), CheckBox)
    '    Dim chkOrderInvoiced As CheckBox = DirectCast(rowGridView.FindControl("chkOrderInvoiced"), CheckBox)
    '    Dim chkOrderShipped As CheckBox = DirectCast(rowGridView.FindControl("chkOrderShipped"), CheckBox)
    '    Dim hidOrderID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderID"), HiddenField)
    '    Dim hidOrderStatus As HiddenField = DirectCast(rowGridView.FindControl("hidOrderStatus"), HiddenField)
    '    Dim chkOrderCancelled As CheckBox = DirectCast(rowGridView.FindControl("chkOrderCancelled"), CheckBox)

    '    OrdersBLL._UpdateStatus(hidOrderID.Value, True, chkOrderPaid.Checked, chkOrderShipped.Checked, chkOrderInvoiced.Checked, hidOrderStatus.Value, "", chkOrderCancelled.Checked)

    '    'Email order update?
    '    If chkInformCustomers.Checked Then
    '        Dim hidOrderLanguageID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderLanguageID"), HiddenField)
    '        Dim hidCustomerID As HiddenField = DirectCast(rowGridView.FindControl("hidOrderCustomerID"), HiddenField)

    '        Dim strCustomOrderStatus As String = String.Empty
    '        If chkOrderShipped.Checked Then
    '            strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusShipped") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
    '        ElseIf chkOrderPaid.Checked Then
    '            strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusPaid") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
    '        ElseIf chkOrderInvoiced.Checked Then
    '            strCustomOrderStatus = GetGlobalResourceObject("Kartris", "ContentText_OrderStatusInvoiced") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
    '        ElseIf chkOrderCancelled.Checked Then
    '            strCustomOrderStatus = GetGlobalResourceObject("_Orders", "ContentText_OrderStatusCancelled") & IIf(String.IsNullOrEmpty(hidOrderStatus.Value), "", vbCrLf & hidOrderStatus.Value)
    '        Else
    '            strCustomOrderStatus = hidOrderStatus.Value
    '        End If
    '        Dim strEmailFrom As String = LanguagesBLL.GetEmailFrom(CInt(hidOrderLanguageID.Value))
    '        Dim strEmailTo As String = UsersBLL.GetEmailByID(CInt(hidCustomerID.Value))
    '        Dim strEmailText As String
    '        Dim strSubjectLine As String = GetGlobalResourceObject("Email", "EmailText_OrderUpdateFrom") & " " & GetGlobalResourceObject("Kartris", "Config_Webshopname")
    '        strEmailText = GetGlobalResourceObject("Email", "EmailText_OrderStatusUpdated").Replace("[order_status]", strCustomOrderStatus) & vbCrLf & vbCrLf & WebShopURL() & "CustomerViewOrder.aspx?O_ID=" & intCurrentID
    '        SendEmail(strEmailFrom, strEmailTo, strSubjectLine, strEmailText)
    '    End If

    'End Sub



End Class
