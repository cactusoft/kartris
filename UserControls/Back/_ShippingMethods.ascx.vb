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
Imports KartSettingsManager
Partial Class UserControls_Back_ShippingMethods
    Inherits System.Web.UI.UserControl

    Public Event UpdateSaved()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        valRequiredOrderBy.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingMethods
        valCompareOrderBy.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingMethods
        valSummary.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingMethods
        lnkBtnSaveShippingMethod.ValidationGroup = LANG_ELEM_TABLE_TYPE.ShippingMethods

        If Not Page.IsPostBack Then
            LoadShippingMethods()
        End If

        If GetShippingMethodID() = 0 Then
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.ShippingMethods, True)
        Else
            _UC_LangContainer.CreateLanguageStrings(LANG_ELEM_TABLE_TYPE.ShippingMethods, False, GetShippingMethodID())
        End If


    End Sub

    Private Sub LoadShippingMethods()

        Dim tblShippingMethods As New DataTable
        tblShippingMethods = ShippingBLL._GetShippingMethdsByLanguage(Session("_LANG")) '' should be the default user's language

        gvwShippingMethods.DataSource = tblShippingMethods
        gvwShippingMethods.DataBind()
        'Hide Tax Rate 2 dropdown if not active
        If TaxRegime.VTax_Type2 <> "rate" Then
            gvwShippingMethods.Columns(2).Visible = False
        End If
        updShippingMethodsList.Update()

    End Sub

    Private Sub LoadShippingMethodInformation()

        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.ShippingMethods, False, GetShippingMethodID())
        '' The following line .. read the value of "litOrderBy" which holds the value of the 
        ''      'SM_OrderByValue' field .. to reduce the db calls
        txtOrderBy.Text = CType(gvwShippingMethods.SelectedRow.Cells(0).FindControl("litOrderBy"), Literal).Text

        chkShippingMethodLive.Checked = CType(gvwShippingMethods.SelectedRow.Cells(1).FindControl("chkLive"), CheckBox).Checked

        lnkBtnDeleteShippingMethod.Visible = True

        litShippingMethodNameInfo.Text = ShippingBLL._GetShippingMethodNameByID(GetShippingMethodID(), Session("_LANG"))

        PopulateTaxBandDropdowns()
        Try
            If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then ddlTaxBand.SelectedValue = _
                CInt(CType(gvwShippingMethods.SelectedRow.Cells(0).FindControl("hidTaxBand"), HiddenField).Value)
            If TaxRegime.VTax_Type2 = "rate" Then ddlTaxBand2.SelectedValue =
                CInt(CType(gvwShippingMethods.SelectedRow.Cells(0).FindControl("hidTaxBand2"), HiddenField).Value)
        Catch ex As Exception

        End Try

    End Sub
    Private Sub ClearRateInformation()

        litShippingMethodNameRates.Text = Nothing
        rptShippingRateZones.DataSource = Nothing
        rptShippingRateZones.DataBind()

    End Sub
    Private Sub LoadShippingMethodRates()

        ClearRateInformation()

        Dim tblShippingMethodZones As New DataTable
        tblShippingMethodZones = ShippingBLL._GetShippingZonesByMethod(GetShippingMethodID())

        rptShippingRateZones.DataSource = tblShippingMethodZones
        rptShippingRateZones.DataBind()

        litShippingMethodNameRates.Text = ShippingBLL._GetShippingMethodNameByID(GetShippingMethodID(), Session("_LANG"))


        '' Add Shipping Zone part
        ddlShippingZonesToCopy.Items.Clear()
        ddlShippingZonesToAdd.Items.Clear()

        Dim tblZones As New DataTable
        tblZones = ShippingBLL._GetShippingZonesByLanguage(Session("_LANG"))

        ddlShippingZonesToCopy.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_None"), 0))

        For Each row In tblZones.Rows
            If tblShippingMethodZones.Select("S_ShippingZoneID=" & row("SZ_ID")).GetLength(0) > 0 Then
                ddlShippingZonesToCopy.Items.Add(New ListItem(row("SZ_Name"), row("SZ_ID")))
            Else
                ddlShippingZonesToAdd.Items.Add(New ListItem(row("SZ_Name"), row("SZ_ID")))
            End If
        Next
        If ddlShippingZonesToAdd.Items.Count > 0 Then
            pnlAddZone.Visible = True
        Else
            pnlAddZone.Visible = False
        End If

    End Sub

    Private Sub PrepareNewShippingMethod()
        PopulateTaxBandDropdowns()
        litShippingMethodID.Text = "0"
        litShippingMethodNameInfo.Text = GetGlobalResourceObject("_Shipping", "ContentText_NewShippingMethod")
        _UC_LangContainer.CreateLanguageStrings( _
                LANG_ELEM_TABLE_TYPE.ShippingMethods, True)
        txtOrderBy.Text = "0"
        chkShippingMethodLive.Checked = False

        lnkBtnDeleteShippingMethod.Visible = False
        phdMethodsList.Visible = False

        mvwShippingMethods.SetActiveView(viwShippingMethodInfo)
        updShippingMethodDetails.Update()
    End Sub

    Private Function GetShippingMethodID() As Byte
        If IsNumeric(litShippingMethodID.Text) Then
            Return CByte(litShippingMethodID.Text)
        End If
        litShippingMethodID.Text = "0"
        Return 0
    End Function

    Protected Sub gvwShippingMethods_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwShippingMethods.RowCommand
        Try
            gvwShippingMethods.SelectedIndex = CInt(e.CommandArgument)
        Catch ex As Exception
            Return
        End Try
        Select Case e.CommandName
            Case "EditShippingMethod"
                mvwShippingMethods.SetActiveView(viwShippingMethodInfo)
                litShippingMethodID.Text = gvwShippingMethods.SelectedValue()
                LoadShippingMethodInformation()
                updShippingMethodDetails.Update()
                phdMethodsList.Visible = False
            Case "ShowRates"
                mvwShippingMethods.SetActiveView(viwShippingMethodRates)
                litShippingMethodID.Text = gvwShippingMethods.SelectedValue()
                LoadShippingMethodRates()
                updShippingMethodDetails.Update()
                phdMethodsList.Visible = False
            Case ""

        End Select
    End Sub

    Protected Sub lnkAddNewShippingMethod_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkAddNewShippingMethod.Click
        PrepareNewShippingMethod()
    End Sub

    Private Sub BackToShippingMethodList()
        litShippingMethodID.Text = ""
        mvwShippingMethods.SetActiveView(viwShippingMethodEmpty)
        updShippingMethodDetails.Update()
        phdMethodsList.Visible = True
        updShippingMethodsList.Update()
    End Sub

    Protected Sub lnkBtnCancelShippingMethod_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancelShippingMethod.Click
        BackToShippingMethodList()
    End Sub

    Protected Sub lnkBtnSaveShippingMethod_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveShippingMethod.Click

        If SaveChanges() Then
            DataChanged()
        End If

    End Sub

    Protected Sub lnkBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBack.Click
        BackToShippingMethodList()
    End Sub

    Public Function SaveChanges() As Boolean

        If GetShippingMethodID() = 0 Then
            '' if new => INSERT
            If Not SaveShippingMethod(DML_OPERATION.INSERT) Then Return False
        Else
            '' if update => UPDATE
            If Not SaveShippingMethod(DML_OPERATION.UPDATE) Then Return False
        End If

        Return True

    End Function

    Private Function SaveShippingMethod(ByVal enumOperation As DML_OPERATION) As Boolean

        Dim tblLanguageContetns As New DataTable
        tblLanguageContetns = _UC_LangContainer.ReadContent()

        Dim blnLive As Boolean = chkShippingMethodLive.Checked
        Dim numOrderBy As Byte = CByte(txtOrderBy.Text)

        Dim bytTaxBand As Byte = 0
        Dim bytTaxBand2 As Byte = 0
        If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then bytTaxBand = CByte(ddlTaxBand.SelectedValue)
        If TaxRegime.VTax_Type2 = "rate" Then bytTaxBand2 = CByte(ddlTaxBand2.SelectedValue)

        Dim strMessage As String = ""
        Select Case enumOperation
            Case DML_OPERATION.INSERT
                If Not ShippingBLL._AddNewShippingMethod(tblLanguageContetns, blnLive, numOrderBy, bytTaxBand, bytTaxBand2, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
            Case DML_OPERATION.UPDATE
                If Not ShippingBLL._UpdateShippingMethod(tblLanguageContetns, GetShippingMethodID(), blnLive, numOrderBy, bytTaxBand, bytTaxBand2, strMessage) Then
                    _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                    Return False
                End If
        End Select

        Return True

    End Function

    Protected Sub lnkBtnDeleteShippingMethod_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnDeleteShippingMethod.Click
        _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.Confirmation, GetGlobalResourceObject("_Kartris", "ContentText_ConfirmDeleteItemUnspecified"))
    End Sub

    ''' <summary>
    ''' if the delete is confirmed "Yes is chosen"
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub _UC_PopupMsg_Confirmed() Handles _UC_PopupMsg.Confirmed
        Dim strMessage As String = ""
        If ShippingBLL._DeleteShippingMethod(GetShippingMethodID(), strMessage) Then
            DataChanged()
        Else
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
    End Sub

    Private Sub DataChanged()
        RaiseEvent UpdateSaved()
        BackToShippingMethodList()
        LoadShippingMethods()

        phdMethodsList.Visible = True

    End Sub

    Protected Sub rptShippingRateZones_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptShippingRateZones.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then

            Dim numZoneID As Byte = CByte(CType(e.Item.FindControl("litShippingZoneID"), Literal).Text)

            CType(e.Item.FindControl("_UC_ShippingRates"),  _
            UserControls_Back_ShippingRates).GetShippingRates( _
               GetShippingMethodID(), numZoneID)

        End If
    End Sub

    Protected Sub ShippingRatesUpdated()
        LoadShippingMethodRates()
        updShippingMethodDetails.Update()
        RaiseEvent UpdateSaved()
    End Sub

    Protected Sub btnAddZone_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAddZone.Click
        If AddZoneRate() Then
            ShippingRatesUpdated()
        End If
    End Sub

    Private Function AddZoneRate() As Boolean
        Dim strMessage As String = ""
        If ddlShippingZonesToCopy.SelectedValue = 0 Then
            '' Add New Zone
            If Not ShippingBLL._AddNewShippingRate(GetShippingMethodID(), CByte(ddlShippingZonesToAdd.SelectedValue()), _
                                                  999999, 0, "", strMessage) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Return False
            End If
        Else
            '' Copy Zone
            If Not ShippingBLL._CopyRates(GetShippingMethodID(), CByte(ddlShippingZonesToCopy.SelectedValue()), _
                                              CByte(ddlShippingZonesToAdd.SelectedValue()), _
                                                  strMessage) Then
                _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
                Return False
            End If

        End If

        Return True
    End Function
    Private Sub PopulateTaxBandDropdowns()
        If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then
            If ddlTaxBand.Items.Count <= 1 Then
                ddlTaxBand.DataTextField = "T_TaxRateString"
                ddlTaxBand.DataValueField = "T_ID"
                ddlTaxBand.DataSource = GetTaxRateFromCache()
                ddlTaxBand.DataBind()
            End If
            valCompareTaxBand.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
        End If
        If TaxRegime.VTax_Type2 = "rate" Then
            If ddlTaxBand2.Items.Count <= 1 Then
                ddlTaxBand2.DataTextField = "T_TaxRateString"
                ddlTaxBand2.DataValueField = "T_ID"
                ddlTaxBand2.DataSource = GetTaxRateFromCache()
                ddlTaxBand2.DataBind()
            End If
            valCompareTaxBand2.ValidationGroup = LANG_ELEM_TABLE_TYPE.Versions
        End If
    End Sub
End Class
