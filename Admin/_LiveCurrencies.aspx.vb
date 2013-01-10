﻿'========================================================================
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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions
Imports CkartrisFormatErrors
Imports KartSettingsManager
Imports CKartrisLimitedServices
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

        Dim sbdIsoList As New StringBuilder(""), strBaseISO As String = ""
        For Each drwTempCurrency As DataRow In tblTempCurrencies.Rows
            Dim strCurrencyName As String = ""
            strCurrencyName = CStr(LanguageElementsBLL.GetElementValue(Session("_LANG"), _
                                    LANG_ELEM_TABLE_TYPE.Currencies, LANG_ELEM_FIELD_NAME.Name, CLng(drwTempCurrency("CUR_ID"))))
            tblCurrencies.Rows.Add(CByte(drwTempCurrency("CUR_ID")), _
                                   strCurrencyName, drwTempCurrency("CUR_ISOCode"), drwTempCurrency("CUR_ExchangeRate"), "")
            sbdIsoList.Append(drwTempCurrency("CUR_ISOCode")) : sbdIsoList.Append(",")
            If CDbl(drwTempCurrency("CUR_ExchangeRate")) = 1 Then strBaseISO = drwTempCurrency("CUR_ISOCode")
        Next

        Dim strMessage As String = Nothing
        If CKartrisLimitedServices.ReadLiveCurrencyRates(strBaseISO, sbdIsoList.ToString, tblCurrencies, strMessage) Then
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

            If strCurrentRate = 1 Then
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
                    If IsNumeric(strNewCurrency) AndAlso CSng(strNewCurrency) > 0 Then
                        CurrenciesBLL._UpdateCurrencyRate(CByte(strCurrencyID), HandleDecimalValues(strNewCurrency))
                    End If
                End If
            Next
            Return True
        Catch ex As Exception
        End Try

        Return False
    End Function

    Protected Sub ShowMasterUpdateMessage()
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub
End Class
