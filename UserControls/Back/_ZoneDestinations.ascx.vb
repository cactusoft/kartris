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
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions

Partial Class UserControls_Back_ZoneDestinations
    Inherits System.Web.UI.UserControl

    Public Event ShowMasterUpdate()

    ''' <summary>
    ''' determines whether to show country group links at top
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public WriteOnly Property ShowGroupLinks() As Boolean
        Set(ByVal value As Boolean)
            phdFiltersUC.Visible = value
        End Set
    End Property

    Public Event _UCEvent_DataUpdated()

    Public Sub GetZoneDestinations(Optional ByVal numShippingZoneID As Byte = 0, Optional ByVal blnClearFilter As Boolean = True)

        phdNoDestinations.Visible = False

        dtlDestinations.DataSource = Nothing
        dtlDestinations.DataBind()

        Dim tblZoneDestinations As New DataTable
        If numShippingZoneID = 0 Then
            '' Showing all the destinations.. used in the _destinations.aspx page
            phdFilterZoneArea.Visible = True
            tblZoneDestinations = ShippingBLL._GetDestinationsByLanguage(Session("_LANG"))
        Else
            phdFilterZoneArea.Visible = False
            tblZoneDestinations = ShippingBLL._GetDestinationsByZone(numShippingZoneID, Session("_LANG"))
        End If
        If tblZoneDestinations.Rows.Count = 0 Then
            phdNoDestinations.Visible = True
            phdFilters.Visible = False
            updMain.Update()
            Return
        End If

        litShippingZoneID.Text = CStr(numShippingZoneID)

        If blnClearFilter Then
            litSelectedFilterType.Text = ""
            litSelectedFilterValue.Text = ""
        End If

        Dim dvwDestinations As New DataView
        dvwDestinations = tblZoneDestinations.DefaultView

        Select Case litSelectedFilterType.Text
            Case "ALPHA"
                dvwDestinations.RowFilter = "D_Name LIKE '" & litSelectedFilterValue.Text & "%'"
            Case "ISO"
                dvwDestinations.RowFilter = "D_IsoCode = '" & litSelectedFilterValue.Text & "'"
            Case "ZONE"
                dvwDestinations.RowFilter = "D_ShippingZoneID = " & litSelectedFilterValue.Text
        End Select

        'They come out of db sorted by ID, so
        'here we sort by name
        dvwDestinations.Sort = "D_Name ASC"

        dtlDestinations.DataSource = dvwDestinations
        dtlDestinations.DataBind()

        updMain.Update()

    End Sub

    Private Sub ShowFilters()
        phdFilters.Visible = True

        '' ALPHABET FILTERS
        phdFilterByAlpha.Controls.Clear()
        Dim lnkBtnFilter As New LinkButton
        Dim litSeparator As New Literal
        Dim strLetters As String = ""
        For i As Int16 = 65 To 90
            lnkBtnFilter = New LinkButton
            lnkBtnFilter.ID = "lnkBtnFilterLetter_" & Chr(i)
            lnkBtnFilter.Text = Chr(i)
            lnkBtnFilter.CommandName = "ALPHA"
            lnkBtnFilter.CommandArgument = Chr(i)
            AddHandler lnkBtnFilter.Click, AddressOf FilterLinkClicked
            phdFilterByAlpha.Controls.Add(lnkBtnFilter)

            litSeparator = New Literal
            litSeparator.ID = "litAlpha_" & Chr(i)
            litSeparator.Text = ""
            phdFilterByAlpha.Controls.Add(litSeparator)
        Next

        '' ISO FILTERS
        phdFilterByISO.Controls.Clear()
        Dim tblISOCodes As DataTable = ShippingBLL._GetISOCodesForFilter()
        Dim intCounter As Integer = 0
        For Each row As DataRow In tblISOCodes.Rows
            intCounter += 1
            lnkBtnFilter = New LinkButton
            lnkBtnFilter.ID = "lnkBtnFilterLetter_" & row("D_ISOCode")
            lnkBtnFilter.Text = row("D_ISOCode")
            lnkBtnFilter.CommandName = "ISO"
            lnkBtnFilter.CommandArgument = row("D_ISOCode")
            AddHandler lnkBtnFilter.Click, AddressOf FilterLinkClicked
            phdFilterByISO.Controls.Add(lnkBtnFilter)

            litSeparator = New Literal
            litSeparator.ID = "litISO_" & intCounter
            litSeparator.Text = ""
            phdFilterByISO.Controls.Add(litSeparator)
        Next

        '' SHIPPING ZONES
        If phdFilterZoneArea.Visible Then
            phdFilterByZones.Controls.Clear()
            Dim tblShippingZones As New DataTable
            tblShippingZones = ShippingBLL._GetShippingZonesByLanguage(Session("_LANG"))
            For Each row As DataRow In tblShippingZones.Rows
                lnkBtnFilter = New LinkButton
                lnkBtnFilter.ID = "lnkBtnFilterLetter_" & row("SZ_ID")
                lnkBtnFilter.Text = row("SZ_Name")
                lnkBtnFilter.CommandName = "ZONE"
                lnkBtnFilter.CommandArgument = row("SZ_ID")
                AddHandler lnkBtnFilter.Click, AddressOf FilterLinkClicked
                phdFilterByZones.Controls.Add(lnkBtnFilter)

                litSeparator = New Literal
                litSeparator.ID = "litZone_" & row("SZ_ID")
                litSeparator.Text = "<br />"
                phdFilterByZones.Controls.Add(litSeparator)
            Next
        End If


    End Sub

    Protected Sub FilterLinkClicked(ByVal sender As Object, ByVal e As System.EventArgs)
        dtlDestinations.SelectedIndex = -1
        litSelectedFilterType.Text = CType(sender, LinkButton).CommandName
        litSelectedFilterValue.Text = CType(sender, LinkButton).CommandArgument
        GetZoneDestinations(GetShippingZoneID(), False)
        ShowFilters()
    End Sub

    Protected Sub dtlZoneDestinations_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.DataListCommandEventArgs) Handles dtlDestinations.ItemCommand
        Select Case e.CommandName
            Case "EditDestination"
                dtlDestinations.SelectedIndex = e.Item.ItemIndex
                GetZoneDestinations(GetShippingZoneID(), False)
            Case "CancelDestination"
                dtlDestinations.SelectedIndex = -1
                GetZoneDestinations(GetShippingZoneID(), False)
            Case "SaveDestination"
                If SaveDestination(e.Item) Then
                    dtlDestinations.SelectedIndex = -1
                    GetZoneDestinations(GetShippingZoneID(), False)
                    RaiseEvent _UCEvent_DataUpdated()
                End If
        End Select

    End Sub

    Private Function SaveDestination(ByVal itm As DataListItem) As Boolean

        Dim tblLanguageContents As New DataTable
        tblLanguageContents = CType(itm.FindControl("_UC_LangContainer"), _LanguageContainer).ReadContent()

        Dim numDestinationID As Short = CShort(CType(itm.FindControl("litDestinationID"), Literal).Text)
        Dim strISOCode As String = CType(itm.FindControl("txtISOCode2Letters"), TextBox).Text.ToUpper()
        Dim strISOCode3Letters As String = CType(itm.FindControl("txtISOCode3Letters"), TextBox).Text.ToUpper()
        Dim strISONumeric As String = CType(itm.FindControl("txtISONumeric"), TextBox).Text
        Dim numZoneID As Byte = CByte(CType(itm.FindControl("ddlShippingZone"), DropDownList).SelectedValue)
        Dim strRegion As String = CStr(CType(itm.FindControl("txtRegion"), TextBox).Text)
        Dim sngTax1 As Single = 0.0F
        Dim sngTax2 As Single = 0.0F

        If TaxRegime.DTax_Type = "rate" Then
            sngTax1 = HandleDecimalValues(CType(itm.FindControl("txtTax"), TextBox).Text)
            sngTax1 = sngTax1 / 100
        Else
            sngTax1 = IIf(CType(itm.FindControl("chkTax"), CheckBox).Checked, 1.0F, 0.0F)
        End If

        If TaxRegime.DTax_Type2 <> "" Then
            If TaxRegime.DTax_Type2 = "rate" Then
                sngTax2 = HandleDecimalValues(CType(itm.FindControl("txtTax2"), TextBox).Text)
            Else
                sngTax2 = IIf(CType(itm.FindControl("chkTax2"), CheckBox).Checked, 1.0F, 0.0F)
            End If
        End If

        Dim blnLive As Boolean = CType(itm.FindControl("chkLive"), CheckBox).Checked

        Dim strMessage As String = ""

        If Not ShippingBLL._UpdateDestination(tblLanguageContents, numDestinationID, numZoneID, _
                                    sngTax1, sngTax2, strISOCode, strISOCode3Letters, strISONumeric, strRegion, blnLive, strMessage, "") Then
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
            Return False
        Else
            For Each dicEntry As DictionaryEntry In HttpContext.Current.Cache
                Dim strCacheKey As String = DirectCast(dicEntry.Key, String)
                If strCacheKey.Contains("CountryList") Then HttpContext.Current.Cache.Remove(strCacheKey)
            Next
            RaiseEvent ShowMasterUpdate()
        End If
        Return True
    End Function

    Private Function GetShippingZoneID() As Byte
        If IsNumeric(litShippingZoneID.Text) Then
            Return CByte(litShippingZoneID.Text)
        End If
        litShippingZoneID.Text = "0"
        Return 0
    End Function

    Protected Sub dtlDestinations_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs) Handles dtlDestinations.ItemDataBound
        If e.Item.ItemType = ListItemType.SelectedItem Then

            Dim numDestinationID As Short = CShort(CType(e.Item.FindControl("litDestinationID"), Literal).Text)

            CType(e.Item.FindControl("_UC_LangContainer"),  _
                _LanguageContainer).CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.Destination, False, numDestinationID)

            Dim ddlZones As DropDownList = CType(e.Item.FindControl("ddlShippingZone"), DropDownList)
            Dim tblZones As New DataTable
            tblZones = ShippingBLL._GetShippingZonesByLanguage(Session("_LANG"))
            ddlZones.DataSource = tblZones
            ddlZones.DataBind()
            ddlZones.SelectedValue = CType(e.Item.FindControl("litDestinationZoneID"), Literal).Text

            If TaxRegime.DTax_Type = "rate" Then
                Dim txtTax As TextBox = CType(e.Item.FindControl("txtTax"), TextBox)
                'multiply database value to 100 to display actual percent
                If IsNumeric(txtTax.Text) Then txtTax.Text = txtTax.Text * 100
                txtTax.Text = _HandleDecimalValues(txtTax.Text)
            End If

        End If
        If TaxRegime.DTax_Type = "rate" Then
            If e.Item.ItemType = ListItemType.AlternatingItem OrElse e.Item.ItemType = ListItemType.Item Then
                Dim litTax As Literal = CType(e.Item.FindControl("litTax"), Literal)
                'multiply database value to 100 to display actual percent
                If IsNumeric(litTax.Text) Then litTax.Text = litTax.Text * 100
                litTax.Text = _HandleDecimalValues(litTax.Text)
                If IsNumeric(litTax.Text) AndAlso litTax.Text > 0 Then litTax.Text += "%"
            End If
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Me.IsPostBack Then

            dtlDestinations.DataSource = Nothing
            dtlDestinations.DataBind()

            updMain.Update()
        Else
            dtlDestinations.Visible = True
            If dtlDestinations.SelectedIndex >= 0 Then
                Dim numDestinationID As Short = CShort(CType(dtlDestinations.Items(dtlDestinations.SelectedIndex).FindControl("litDestinationID"), Literal).Text)

                CType(dtlDestinations.Items(dtlDestinations.SelectedIndex).FindControl("_UC_LangContainer"),  _
                    _LanguageContainer).CreateLanguageStrings( _
                    LANG_ELEM_TABLE_TYPE.Destination, False, numDestinationID)
            End If

        End If
        ShowFilters()

    End Sub


End Class
