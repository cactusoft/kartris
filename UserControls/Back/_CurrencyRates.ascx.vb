'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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
Imports KartSettingsManager

Partial Class UserControls_Back_CurrencyRates
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        valRequiredSymbol.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredCurrency.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredExchangeRate.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredFormat.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredIsoFormat.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredDecimalPoint.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredRoundNumbers.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valRequiredIsoNumeric.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.Currencies

        'Add style div to the base currency explanation
        If Not Me.IsPostBack Then
            litBaseCurrency.Text = "<div class=""infomessage"">" & litBaseCurrency.Text & "</div>"
        End If

        If GetCurrencyID() = "0" Then
            _UC_LangContainer.CreateLanguageStrings( _
            LANG_ELEM_TABLE_TYPE.Currencies, True)
        Else
            _UC_LangContainer.CreateLanguageStrings( _
            LANG_ELEM_TABLE_TYPE.Currencies, False, GetCurrencyID())
        End If
        If Not Page.IsPostBack Then
            LoadCurrencies()
        End If
    End Sub

    Private Sub LoadCurrencies()
        Dim tblCurrencies As DataTable = GetCurrenciesFromCache()

        gvwCurrencies.DataSource = tblCurrencies
        gvwCurrencies.DataBind()

        updCurrencyList.Update()
    End Sub

    Protected Sub chkUseDecimal_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles chkUseDecimal.CheckedChanged
        valRequiredDecimalPoint.Enabled = chkUseDecimal.Checked
        txtDecimalPoint.Enabled = chkUseDecimal.Checked
        updCurrency.Update()
    End Sub

    Private Sub LoadCurrency(ByVal CurrencyID As Byte)

        Dim tblCurrency As New DataTable
        Dim rowCurrencies As DataRow()

        rowCurrencies = CurrenciesBLL._GetByCurrencyID(CurrencyID)

        If rowCurrencies.Length = 0 Then lnkBtnDelete.Visible = False : Return

        _UC_LangContainer.CreateLanguageStrings( _
            LANG_ELEM_TABLE_TYPE.Currencies, False, CurrencyID)

        litCurrencyID.Text = CByte(rowCurrencies(0)("CUR_ID"))

        txtSymbol.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_Symbol")))
        txtISOCode.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_ISOCode")))
        txtIsoCodeNumeric.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_ISOCodeNumeric")))
        txtExchangeRate.Text = _HandleDecimalValues(CStr(FixNullFromDB(rowCurrencies(0)("CUR_ExchangeRate"))))
        chkUseDecimal.Checked = CBool(rowCurrencies(0)("CUR_HasDecimals"))
        chkLive.Checked = CBool(rowCurrencies(0)("CUR_Live"))
        txtFormat.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_Format")))
        txtIsoFormat.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_IsoFormat")))
        txtDecimalPoint.Text = CStr(FixNullFromDB(rowCurrencies(0)("CUR_DecimalPoint")))
        txtRoundNumbers.Text = FixNullFromDB(rowCurrencies(0)("CUR_RoundNumbers"))

        If CByte(rowCurrencies(0)("CUR_ID")) = CurrenciesBLL.GetDefaultCurrency() Then
            lnkBtnDelete.Visible = False
            litBaseCurrency.Visible = True
            txtExchangeRate.Enabled = False
            chkLive.Enabled = False
        Else
            lnkBtnDelete.Visible = True
            litBaseCurrency.Visible = False
            txtExchangeRate.Enabled = True
            chkLive.Enabled = True
        End If

        txtDecimalPoint.Enabled = chkUseDecimal.Checked

    End Sub

    Protected Sub gvwCurrencies_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwCurrencies.RowCommand
        If e.CommandName = "CreateNewCurrency" Then
            PrepareNewCurrency()
            phdCurrencyDetails.Visible = True
            updCurrency.Update()
        ElseIf e.CommandName = "setdefault" Then
            Dim strMessage As String = String.Empty
            If CurrenciesBLL._SetDefault(e.CommandArgument, strMessage) Then
                RefreshCurrencyCache()
                LoadCurrencies()
                RaiseEvent ShowMasterUpdate()
            Else
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        End If
    End Sub

    Private Sub PrepareNewCurrency()

        phdCurrencyDetails.Visible = True
        phdList.Visible = False

        _UC_LangContainer.CreateLanguageStrings( _
            LANG_ELEM_TABLE_TYPE.Currencies, True)

        litCurrencyID.Text = "0"
        txtSymbol.Text = Nothing
        txtISOCode.Text = Nothing
        txtIsoCodeNumeric.Text = Nothing
        txtExchangeRate.Text = Nothing
        chkUseDecimal.Checked = True
        chkLive.Checked = True
        txtFormat.Text = Nothing
        txtIsoFormat.Text = Nothing
        txtDecimalPoint.Text = Nothing
        txtRoundNumbers.Text = Nothing

        txtExchangeRate.Enabled = True
        chkLive.Enabled = True

        lnkBtnDelete.Visible = False

    End Sub

    Protected Sub gvwCurrencies_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwCurrencies.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            CType(e.Row.Cells(3).FindControl("litCUR_ExchangeRate"), Literal).Text = _
                _HandleDecimalValues(CType(e.Row.Cells(3).FindControl("litCUR_ExchangeRate"), Literal).Text)
            Dim lnkDefault As LinkButton = CType(e.Row.Cells(3).FindControl("lnkBtnSetDefault"), LinkButton)
            If CurrenciesBLL.GetDefaultCurrency() = lnkDefault.CommandArgument Then
                lnkDefault.Visible = False
            End If
        End If
    End Sub

    Protected Sub gvwCurrencies_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvwCurrencies.SelectedIndexChanged
        LoadCurrency(CByte(gvwCurrencies.SelectedValue()))
        phdCurrencyDetails.Visible = True
        phdList.Visible = False
        updCurrency.Update()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If SaveChanges() Then
            LoadCurrencies()
            HideDetails()
        End If
    End Sub

    Private Function SaveChanges() As Boolean
        If GetCurrencyID() = 0 Then '' new
            If Not SaveCurrency(DML_OPERATION.INSERT) Then Return False
        Else                        '' update
            If Not SaveCurrency(DML_OPERATION.UPDATE) Then Return False
        End If
        Return True
    End Function

    Private Function SaveCurrency(ByVal enumOperation As DML_OPERATION) As Boolean
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 1. Language Contents
        Dim tblLanguageContents As New DataTable
        tblLanguageContents = _UC_LangContainer.ReadContent()

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        '' 2. Currency Main Info.
        Dim strSymbol As String = txtSymbol.Text
        Dim strIsoCode As String = txtISOCode.Text
        Dim strIsoCodeNumeric As String = txtIsoCodeNumeric.Text
        Dim numExchangeRate As Decimal = txtExchangeRate.Text
        Dim blnUseDecimal As Boolean = chkUseDecimal.Checked
        Dim blnLive As Boolean = chkLive.Checked
        Dim strFormat As String = txtFormat.Text
        Dim strIsoFormat As String = txtIsoFormat.Text
        Dim chrDecimalPoint As Char = txtDecimalPoint.Text
        Dim numRoundNumbers As Byte = txtRoundNumbers.Text

        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        ' 3. Saving the changes
        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.UPDATE
                If Not CurrenciesBLL._UpdateCurrency( _
                                tblLanguageContents, GetCurrencyID(), strSymbol, strIsoCode, strIsoCodeNumeric, numExchangeRate, _
                                blnUseDecimal, blnLive, strFormat, strIsoFormat, chrDecimalPoint, numRoundNumbers, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.INSERT
                If Not CurrenciesBLL._AddNewCurrency( _
                                tblLanguageContents, strSymbol, strIsoCode, strIsoCodeNumeric, numExchangeRate, _
                                blnUseDecimal, blnLive, strFormat, strIsoFormat, chrDecimalPoint, numRoundNumbers, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        RefreshCurrencyCache()

        RaiseEvent ShowMasterUpdate()

        Return True
    End Function

    Private Function GetCurrencyID() As Byte
        If litCurrencyID.Text <> "" Then Return CByte(litCurrencyID.Text)
        Return 0
    End Function

    Private Sub HideDetails()
        phdCurrencyDetails.Visible = False
        phdList.Visible = True
        updCurrency.Update()
    End Sub

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        LoadCurrencies()
        HideDetails()
    End Sub

    Protected Sub lnkBtnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDelete.Click
        Dim strMessage As String = Replace(GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItem"), "[itemname]", CurrenciesBLL.CurrencyCode(GetCurrencyID()))
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, strMessage)
    End Sub

    Public Function ShowBaseCurrency(ByVal numID As Integer) As String
        If numID = CurrenciesBLL.GetDefaultCurrency() Then
            Return "*"
        Else
            Return ""
        End If
    End Function

    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If CurrenciesBLL._DeleteCurrency(GetCurrencyID(), strMessage) Then
            RefreshCurrencyCache()
            LoadCurrencies()
            HideDetails()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub

End Class
