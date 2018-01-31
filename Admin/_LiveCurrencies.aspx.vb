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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports KartSettingsManager
Imports System.Xml.Linq
Imports System.Xml

Partial Class Admin_LiveCurrencies
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Currency", "PageTitle_Currencies") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            Try
                GetCurrenciesUpdate()
                phdCurrencies.Visible = True
                phdCurrenciesNotAccessible.Visible = False
            Catch ex As Exception
                phdCurrencies.Visible = False
                phdCurrenciesNotAccessible.Visible = True
            End Try
        End If

    End Sub

    Private Sub GetCurrenciesUpdate()

        Dim tblTempCurrencies As New DataTable
        tblTempCurrencies = GetCurrenciesFromCache() 'CurrenciesBLL._GetCurrencies()

        Dim tblCurrencies As New DataTable
        tblCurrencies.Columns.Add(New DataColumn("CurrencyID", Type.GetType("System.Byte")))
        tblCurrencies.Columns.Add(New DataColumn("CurrencyName", Type.GetType("System.String")))
        tblCurrencies.Columns.Add(New DataColumn("ISOCode", Type.GetType("System.String")))
        tblCurrencies.Columns.Add(New DataColumn("CurrentRate", Type.GetType("System.String")))
        tblCurrencies.Columns.Add(New DataColumn("NewRate", Type.GetType("System.String")))
        tblCurrencies.Columns.Add(New DataColumn("IsDefault", Type.GetType("System.Boolean")))

        Dim sbdIsoList As New StringBuilder(""), strBaseISO As String = ""
        For Each drwTempCurrency As DataRow In tblTempCurrencies.Rows
            Dim strCurrencyName As String = ""
            strCurrencyName = CStr(LanguageElementsBLL.GetElementValue(Session("_LANG"), _
                                    LANG_ELEM_TABLE_TYPE.Currencies, LANG_ELEM_FIELD_NAME.Name, CLng(drwTempCurrency("CUR_ID"))))

            If CByte(drwTempCurrency("CUR_ID")) = CurrenciesBLL.GetDefaultCurrency() Then
                strBaseISO = drwTempCurrency("CUR_ISOCode")
                tblCurrencies.Rows.Add(CByte(drwTempCurrency("CUR_ID")), _
                                                   strCurrencyName, drwTempCurrency("CUR_ISOCode"), drwTempCurrency("CUR_ExchangeRate"), "", True)
            Else
                tblCurrencies.Rows.Add(CByte(drwTempCurrency("CUR_ID")), _
                                                   strCurrencyName, drwTempCurrency("CUR_ISOCode"), drwTempCurrency("CUR_ExchangeRate"), "", False)
            End If

            sbdIsoList.Append(drwTempCurrency("CUR_ISOCode")) : sbdIsoList.Append(",")
        Next

        Dim strMessage As String = Nothing
        If ReadLiveCurrencyRates(strBaseISO, sbdIsoList.ToString, tblCurrencies, strMessage) Then
            rptCurrencies.DataSource = tblCurrencies
            rptCurrencies.DataBind()
            lnkUpdateCurrencies.Visible = True
            updMain.Update()
        Else
            If Not String.IsNullOrEmpty(strMessage) Then _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            lnkUpdateCurrencies.Visible = False
            Throw New ApplicationException("")
        End If
    End Sub

    Protected Sub rptCurrencies_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptCurrencies.ItemDataBound
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim strCurrentRate As String = ""
            Dim strNewRate As String = ""

            strCurrentRate = CType(e.Item.FindControl("litCurrentRate"), Literal).Text
            strNewRate = CType(e.Item.FindControl("txtNewRate"), TextBox).Text

            If CType(e.Item.FindControl("chkIsDefault"), CheckBox).Checked Then
                CType(e.Item.FindControl("txtNewRate"), TextBox).Enabled = False
            Else
                CType(e.Item.FindControl("txtNewRate"), TextBox).Enabled = True
            End If

            If strCurrentRate > strNewRate Then
                CType(e.Item.FindControl("litCurrentRate"), Literal).Text = "<span class=""undervalue"">" & _HandleDecimalValues(strCurrentRate) & "</span>"
            ElseIf strCurrentRate < strNewRate Then
                CType(e.Item.FindControl("litCurrentRate"), Literal).Text = "<span class=""overvalue"">" & _HandleDecimalValues(strCurrentRate) & "</span>"
            End If
            CType(e.Item.FindControl("txtNewRate"), TextBox).Text = _HandleDecimalValues(strNewRate)
        End If
    End Sub

    Protected Sub lnkUpdateCurrencies_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkUpdateCurrencies.Click
        If UpdateCurrencies() Then
            RefreshCurrencyCache()
            GetCurrenciesUpdate()
            ShowMasterUpdateMessage()
        End If
    End Sub

    Private Function UpdateCurrencies() As Boolean

        Try
            For Each itm As RepeaterItem In rptCurrencies.Items
                If itm.ItemType = ListItemType.Item OrElse _
                    itm.ItemType = ListItemType.AlternatingItem Then

                    Dim strCurrencyID As String = CStr(CType(itm.FindControl("litCurrencyID"), Literal).Text)
                    Dim strNewCurrency As String = CStr(CType(itm.FindControl("txtNewRate"), TextBox).Text)
                    If IsNumeric(strNewCurrency) AndAlso CDec(strNewCurrency) > 0 Then
                        CurrenciesBLL._UpdateCurrencyRate(CByte(strCurrencyID), HandleDecimalValues(strNewCurrency))
                    End If
                End If
            Next
            Return True
        Catch ex As Exception
        End Try

        Return False
    End Function

    Private Function GetBitCoinRate(ByVal strBaseIso As String) As Decimal
        Dim url As String = "https://bitpay.com/api/rates/" & strBaseIso
        Dim xmlDoc As XDocument = Nothing
        Dim numValue As Decimal = 0

        'Put it in a try, in case a bad result is or some
        'other problem like an error
        Try
            'Grab Bitcoin feed with this code that prevents
            'timeouts taking the whole feed down, as at present
            'we expect Bitcoin feeds to be less reliable and
            'also not the primary currency on a site
            Dim reqFeed As System.Net.HttpWebRequest = DirectCast(System.Net.WebRequest.Create(url), System.Net.HttpWebRequest)
            reqFeed.Timeout = 1000 'milliseconds
            Dim resFeed As System.Net.WebResponse = reqFeed.GetResponse()
            Dim responseStream As Stream = resFeed.GetResponseStream()
            Dim reader As New StreamReader(responseStream)
            Dim strResponse As String = reader.ReadToEnd()
            responseStream.Close()

            'Format of response as follows
            '{"code":"GBP","name":"Pound Sterling","rate":302.481272}
            Dim aryResponse As Array = Split(strResponse, """rate"":")
            strResponse = aryResponse(1).Replace("}", "")
            numValue = Math.Round(1 / CDec(strResponse), 12)
        Catch ex As Exception
            'Oh dear
            numValue = 0
        End Try
        Return numValue

    End Function

    Private Function ReadLiveCurrencyRates( _
            ByVal strBaseIso As String, ByVal strIsoList As String, ByRef tblCurrencies As DataTable, _
            ByRef strMessage As String) As Boolean

        Dim url As String = "http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"
        Dim doc As XDocument = XDocument.Load(url)

        Dim gesmes As XNamespace = "http://www.gesmes.org/xml/2002-08-01"
        Dim ns As XNamespace = "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"

        Dim decBaseISORate As Decimal = 0

        'This line retrieves the individual "cube" entries and outputs then as an object with currencyiso and rate properties
        Dim cubes = doc.Descendants(ns + "Cube").Where(Function(x) x.Attribute("currency") IsNot Nothing).Select(Function(x) New With
                                {Key .Currency = CStr(x.Attribute("currency")), Key .Rate = CDec(x.Attribute("rate"))})

        If cubes Is Nothing Then
            Try
                Throw New ApplicationException(GetGlobalResourceObject("_Currency", "ContentText_LiveCurrencyReadError"))
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            End Try
            strMessage = GetGlobalResourceObject("_Currency", "ContentText_LiveCurrencyReadError")
            Return False
        Else
            'retrieve the Base ISO rate first to use as the converter value
            If strBaseIso.ToUpper = "EUR" Then
                decBaseISORate = 1
            Else
                For Each result As Object In cubes
                    If result.Currency = strBaseIso Then decBaseISORate = result.Rate : Exit For
                Next
            End If
            
        End If

        'loop through the results and add the new values to the currencies table
        If cubes.Count > 0 Then
            For Each row As DataRow In tblCurrencies.Rows
                For Each result As Object In cubes
                    If row("ISOCode") = result.Currency Then
                        'rates needs to be divided to the GBP value as they are originally computed against 1 EUR
                        row("NewRate") = Math.Round(result.Rate / decBaseISORate, 8)
                        Exit For
                    ElseIf row("ISOCode") = "EUR" Then
                        'EUR is not in the returned XML so just always consider its value as 1 - its the XML's base currency 
                        'To get its actual rate, just divide it against the base iso rate
                        row("NewRate") = Math.Round(1 / decBaseISORate, 8)
                        Exit For
                    ElseIf row("ISOCode") = "BTC" Then
                        row("NewRate") = GetBitCoinRate(strBaseIso)
                        Exit For
                    End If
                Next
            Next
            Return True
        Else
            Try
                Throw New ApplicationException(GetGlobalResourceObject("_Currency", "ContentText_LiveCurrencyRequestError"))
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod())
            End Try
            strMessage = GetGlobalResourceObject("_Currency", "ContentText_LiveCurrencyRequestError")
            Return False
        End If

    End Function

    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
