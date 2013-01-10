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
Partial Class UserControls_Back_PaymentsList
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
            RefreshPaymentsList()
            GoToCorrectPage()
        End If
    End Sub

    ''' <summary>
    ''' Payments List Call Mode. 
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property CallMode() As String
        Get
            Return ViewState("_Callmode")
        End Get
        Set(ByVal value As String)
            ViewState("_Callmode") = value
        End Set
    End Property

    Public ReadOnly Property RowCount() As Integer
        Get
            Return _RowCount
        End Get
    End Property

    ''' <summary>
    ''' Expects either the Payment Date.
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
    ''' Expects either the Payment Date.
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public Property datGateway() As String
        Get
            Return ViewState("_datGateway")
        End Get
        Set(ByVal value As String)
            ViewState("_datGateway") = value
        End Set
    End Property

    Public Sub RefreshPaymentsList(Optional ByVal blnRetrieveTotalCount As Boolean = True)
        If ViewState("intTotalRowCount") Is Nothing Then blnRetrieveTotalCount = True
        'If the callmode if 'd' then we need to convert the parameters to 'Date'
        Dim tblPaymentsList As DataTable = Nothing

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
            ViewState("_Callmode") = "d"
            ViewState("_datValue1") = strDateQS
        End If

        Dim datValue As Date = Today.Date

        'backend.search.pagesize
        Dim intCurrentPage As Integer = _UC_ItemPager.CurrentPage

        phdDateNavigation.Visible = False

        If ViewState("_datValue1") Is Nothing And ViewState("_datGateway") Is Nothing Then
            ViewState("_Callmode") = "a"
            phdDateNavigation.Visible = False
        Else
            If IsDate(ViewState("_datValue1")) Then
                Try
                    datValue = CkartrisDisplayFunctions.FormatDate(CDate(ViewState("_datValue1")), "d", Session("_LANG"))
                Catch ex As Exception

                End Try

                If datValue = Today Then
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
                phdDateNavigation.Visible = False
            End If
        End If


        tblPaymentsList = OrdersBLL._GetPaymentsFilteredList(ViewState("_Callmode"), ViewState("_datGateway"), ViewState("_datValue1"), intCurrentPage, intRowsPerPage)
        ViewState("intTotalRowCount") = OrdersBLL._GetPaymentsFilteredListCount(ViewState("_Callmode"), ViewState("_datGateway"), ViewState("_datValue1"))

        _RowCount = tblPaymentsList.Rows.Count

        If _RowCount = 0 Then
            'litOLIndicates.Text = GetLocalResourceObject("ContentText_NoOrdersMadeOnThisDay")
            'litOLIndicatesComplete.Text = ""
        Else
            'litOLIndicates.Text = GetLocalResourceObject("ContentText_OrdersListIndicates")
            'litOLIndicatesComplete.Text = GetLocalResourceObject("ContentText_OrdersListIndicatesComplete")
        End If

        If Not blnTableCopied Then
            ViewState("originalValuesDataTable") = tblPaymentsList
            blnTableCopied = True
        End If
        _UC_ItemPager.TotalItems = ViewState("intTotalRowCount")
        _UC_ItemPager.ItemsPerPage = intRowsPerPage
        _UC_ItemPager.PopulatePagerControl()
        gvwPayments.DataSource = tblPaymentsList
        gvwPayments.DataBind()

        'If litOLIndicatesComplete.Visible = False And litOLIndicates.Visible = False Then
        'phdIndicates.Visible = False
        'Else
        'phdIndicates.Visible = True
        'End If
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
                RefreshPaymentsList(False)
            Catch ex As Exception
                'Fail
            End Try
        End If
    End Sub

    Protected Sub PageChanged() Handles _UC_ItemPager.PageChanged
        RefreshPaymentsList(False)
    End Sub

    Private Sub gvwOrders_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwPayments.RowDataBound
        If e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Header And e.Row.RowType <> Web.UI.WebControls.DataControlRowType.Footer Then
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim litPaymentAmount As Literal = DirectCast(e.Row.FindControl("litPaymentAmount"), Literal)
                Dim hidPaymentCurrencyID As HiddenField = DirectCast(e.Row.FindControl("hidPaymentCurrencyID"), HiddenField)
                Dim hidOrderChildID As HiddenField = DirectCast(e.Row.FindControl("hidOrderChildID"), HiddenField)

                Dim numPaymentAmount As Single = CSng(litPaymentAmount.Text)
                Dim srtPaymentCurrencyID As Short = CShort(hidPaymentCurrencyID.Value)

                'Format the Order Total Price base on the Gateway's Currency
                Try
                    litPaymentAmount.Text = CurrenciesBLL.FormatCurrencyPrice(srtPaymentCurrencyID, numPaymentAmount)
                Catch ex As Exception
                    litPaymentAmount.Text = "? " & numPaymentAmount
                End Try

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
    End Sub

    Protected Sub btnDates_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnTomorrow.Click, btnYesterday.Click
        Dim btnThis As LinkButton = DirectCast(sender, LinkButton)
        ViewState("_datValue1") = btnThis.Text
        ViewState("_datGateway") = Nothing
        ViewState("_Callmode") = "d"
        gvwPayments.PageIndex = 0
        RefreshPaymentsList()
    End Sub


End Class