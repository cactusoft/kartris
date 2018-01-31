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
'========================================================================
Partial Class UserControls_Back_CustomersList

    Inherits System.Web.UI.UserControl

    Private _isAffiliates As Boolean = False
    Private _isMailingList As Boolean = False
    Private _isApproved As Boolean = False
    Private _CustomerGroupID As Integer = 0
    Private _RowCount As Integer

    Public Property CustomerGroupID() As Integer
        Get
            Return _CustomerGroupID
        End Get
        Set(ByVal value As Integer)
            _CustomerGroupID = value
        End Set
    End Property

    Public Property isAffiliates() As Boolean
        Get
            Return _isAffiliates
        End Get
        Set(ByVal value As Boolean)
            _isAffiliates = value
        End Set
    End Property

    Public Property isApproved() As Boolean
        Get
            Return _isApproved
        End Get
        Set(ByVal value As Boolean)
            _isApproved = value
        End Set
    End Property

    Public Property isMailingList() As Boolean
        Get
            Return _isMailingList
        End Get
        Set(ByVal value As Boolean)
            _isMailingList = value
        End Set
    End Property

    Public ReadOnly Property RowCount() As Integer
        Get
            Return _RowCount
        End Get
    End Property

    ''' <summary>
    ''' Search Term
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property strSearch() As String
        Get
            Return ViewState("_strSearch")
        End Get
        Set(ByVal value As String)
            ViewState("_strSearch") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            'Pre-fill search box if we're coming back from
            'a customer and sending back the search term
            Dim numPage As Integer = 1
            If IsNumeric(Request.QueryString("Page")) Then numPage = Request.QueryString("Page")
            _UC_ItemPager.CurrentPage = numPage - 1

            RefreshCustomersList()
        End If

    End Sub

    Public Sub RefreshCustomersList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        If ViewState("intTotalRowCount") Is Nothing Then blnRetrieveTotalCount = True
        If blnRetrieveTotalCount Then ViewState("intTotalRowCount") = UsersBLL._GetDataBySearchTermCount(ViewState("_strSearch"), _isAffiliates, _isMailingList, _CustomerGroupID, _isApproved)
        Dim intCurrentPage As Integer = _UC_ItemPager.CurrentPage

        Dim intRowsPerPage As Integer = 25
        Try
            intRowsPerPage = CType(KartSettingsManager.GetKartConfig("backend.display.pagesize"), Double)
        Catch ex As Exception
            'Stays at 25
        End Try

        Dim tblCustomersList As DataTable = UsersBLL._GetDataBySearchTerm(ViewState("_strSearch"), intCurrentPage, intRowsPerPage, _isAffiliates, _isMailingList, _CustomerGroupID, _isApproved)

        'Here we filter customers by account balance if required,
        'to find those in arrears or due refunds
        Dim strFilterQuery As String = ""
        If Request.QueryString("callmode") = "refunds" Then
            strFilterQuery = "(U_CustomerBalance > 0)"
        ElseIf Request.QueryString("callmode") = "arrears" Then
            strFilterQuery = "(U_CustomerBalance < 0)"
        End If

        'If there is a filter statement, we clone the data set
        'and read the filtered rows into that. Otherwise, we
        'just bind grid to the original datatable.
        If strFilterQuery <> "" Then
            'We have a filter
            Dim tblCustomersList2 As DataTable = tblCustomersList.Clone
            Dim drwCustomers As DataRow() = tblCustomersList.[Select]("(U_CustomerBalance<>0)")
            For Each drwCustomer As DataRow In drwCustomers
                tblCustomersList2.ImportRow(drwCustomer)
            Next
            gvwCustomers.DataSource = tblCustomersList2
            gvwCustomers.DataBind()
        Else
            'No filter
            gvwCustomers.DataSource = tblCustomersList
            gvwCustomers.DataBind()
        End If

        'Set up paging and record totals
        If tblCustomersList.Rows.Count = 0 Then
            litNoCustomersFound.Text = "<div class=""noresults"">" & GetGlobalResourceObject("_Kartris", "ContentText_BackSearchNoResults") & "</div>"
        Else
            _UC_ItemPager.TotalItems = ViewState("intTotalRowCount")
            _UC_ItemPager.ItemsPerPage = intRowsPerPage
            _UC_ItemPager.PopulatePagerControl()

            litNoCustomersFound.Text = ""
        End If
    End Sub

    Public Sub ResetCurrentPage()
        _UC_ItemPager.CurrentPage = 0
    End Sub

    Protected Sub PageChanged() Handles _UC_ItemPager.PageChanged
        RefreshCustomersList(False)
    End Sub

    Protected Sub gvwCustomers_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwCustomers.RowDataBound
        Dim drvCustomer As System.Data.DataRowView

        If e.Row.RowType = DataControlRowType.DataRow Then
            drvCustomer = e.Row.DataItem

            Dim lblCustomerBalance As Label = CType(e.Row.FindControl("lblCustomerBalance"), Label)
            If lblCustomerBalance IsNot Nothing Then
                If lblCustomerBalance.Text <> "" Then
                    Dim dblCustomerBalance As Double = CDbl(lblCustomerBalance.Text)
                    lblCustomerBalance.Text = CurrenciesBLL.FormatCurrencyPrice(CurrenciesBLL.GetDefaultCurrency, dblCustomerBalance)
                    If dblCustomerBalance <> 0 Then lblCustomerBalance.Font.Bold = True
                    If dblCustomerBalance > 0 Then lblCustomerBalance.ForeColor = Drawing.Color.Green
                    If dblCustomerBalance < 0 Then lblCustomerBalance.ForeColor = Drawing.Color.Red
                End If
            End If

            Dim objCustomerLink As HtmlAnchor = CType(e.Row.FindControl("lnkCustomer"), HtmlAnchor)

            'Add customer ID to 'select' link
            objCustomerLink.HRef &= drvCustomer.Item("U_ID").ToString

            'Add current page in results to 'select' link
            objCustomerLink.HRef &= "&Page=" & (_UC_ItemPager.CurrentPage + 1).ToString

            'Add current search term(s) to 'select' link
            objCustomerLink.HRef &= "&strSearch=" & Server.UrlEncode(ViewState("_strSearch"))

            If drvCustomer.Item("U_IsAffiliate") And drvCustomer.Item("U_AffiliateCommission") > 0 Then
                CType(e.Row.FindControl("phdPayment"), PlaceHolder).Visible = True
            Else
                CType(e.Row.FindControl("phdPayment"), PlaceHolder).Visible = False
                If _isApproved Then
                    objCustomerLink.HRef &= "&tab=a"
                End If
            End If

        End If

    End Sub

End Class
