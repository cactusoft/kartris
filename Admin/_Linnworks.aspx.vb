
Partial Class Admin_Linnworks
    Inherits _PageBaseClass

    Protected Sub Admin_Linnworks_Load(sender As Object, e As EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Linnworks", "PageTitle_LinnworksIntegration") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        If Not Page.IsPostBack() Then
            CheckToken()
        End If
    End Sub
    Sub CheckToken()
        Dim strToken As String = KartSettingsManager.GetKartConfig("general.linnworks.token")
        If String.IsNullOrEmpty(strToken) Then
            litTokenMessage.Text = GetGlobalResourceObject("_Linnworks", "ContentText_NoSavedToken")
            phdInvalidToken.Visible = True
            phdContents.Visible = False
        ElseIf Not LinnworksServices._IsValidLinnworksToken(strToken) Then
            litTokenMessage.Text = GetGlobalResourceObject("_Linnworks", "ContentText_InvalidToken")
            phdInvalidToken.Visible = True
            phdContents.Visible = False
        Else
            litToken.Text = strToken
            LoadPendingOrders()
            LoadSentOrders()
            LoadlinnworksStock()
            phdInvalidToken.Visible = False
            phdContents.Visible = True
        End If
    End Sub
    Protected Sub btnGenerate_Click(sender As Object, e As EventArgs) Handles btnGenerate.Click
        Dim strMessage As String = ""
        Dim strToken As String = LinnworksServices._GenerateNewLinnworksToken(txtEmail.Text, txtPassword.Text, strMessage)
        If String.IsNullOrEmpty(strToken) Then
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            ConfigBLL._UpdateConfigValue("general.linnworks.token", strToken, False, True)
            litToken.Text = strToken
            CheckToken()
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub
    Sub LoadPendingOrders()
        Dim dt As DataTable = LinnworksServices._GetLinnworksPending()
        gvwPendingOrders.DataSource = dt
        gvwPendingOrders.DataBind()
        litPendingOrdersHidden.Text = dt.Rows.Count
        litTotalPending.Text = "(" & dt.Rows.Count & ")"
        If dt.Rows.Count > 0 Then
            mvwPendingOrders.SetActiveView(viwPendingOrders)
        Else
            mvwPendingOrders.SetActiveView(viwNoPendingOrders)
        End If
        If dt.Rows.Count > 0 Then
            DisableStockSync()
        Else
            EnableStockSync()
        End If
        updKartrisPendingOrders.Update()
    End Sub
    Sub DisableStockSync()
        For Each rw As GridViewRow In gvwStock.Rows
            CType(rw.Cells(0).FindControl("chkSelect"), CheckBox).Enabled = False
        Next
        phdDisableSyn.Visible = True
        phdEnableSync.Visible = False
    End Sub
    Sub EnableStockSync()
        For Each rw As GridViewRow In gvwStock.Rows
            CType(rw.Cells(0).FindControl("chkSelect"), CheckBox).Enabled = True
        Next
        phdDisableSyn.Visible = False
        phdEnableSync.Visible = True
    End Sub
    Sub LoadSentOrders()
        Dim dt As DataTable = LinnworksServices._GetLinnworksOrders()
        gvwSentOrders.DataSource = dt
        gvwSentOrders.DataBind()
        litTotalSent.Text = "(" & dt.Rows.Count & ")"
        If dt.Rows.Count > 0 Then
            mvwSentOrders.SetActiveView(viwSentOrders)
        Else
            mvwSentOrders.SetActiveView(viwNoSentOrders)
        End If
        updKartrisSentOrders.Update()
    End Sub

    Sub LoadlinnworksStock()
        If String.IsNullOrEmpty(litToken.Text) Then CheckToken()
        Dim strMessage As String = Nothing
        Dim dt As DataTable = LinnworksServices._GetLinnworksStockLevel(litToken.Text, strMessage)
        If dt IsNot Nothing Then
            gvwStock.DataSource = dt
            gvwStock.DataBind()
            litTotalStock.Text = "(" & dt.Rows.Count & ")"
            If dt.Rows.Count > 0 Then
                mvwStock.SetActiveView(viwStock)
            Else
                mvwStock.SetActiveView(viwNoStock)
            End If
        Else
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
        End If
        If IsNumeric(litPendingOrdersHidden.Text) AndAlso CInt(litPendingOrdersHidden.Text) > 0 Then
            DisableStockSync()
        Else
            EnableStockSync()
        End If
        updStockLevels.Update()
    End Sub
    Protected Sub gvwPendingOrders_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvwPendingOrders.RowCommand
        If e.CommandName = "send" Then
            SendOrderToLinnworks(e.CommandArgument)
        End If
    End Sub
    Sub SendOrderToLinnworks(intOrderID As Integer)
        Dim strMessage As String = Nothing
        If Not LinnworksServices._CreateNewLinnowrksOrder(intOrderID, litToken.Text, strMessage) Then
            _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
        Else
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
            LoadPendingOrders()
            LoadSentOrders()
            SyncronizeAllStock()
        End If
    End Sub
    Private Sub gvwSentOrders_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwSentOrders.RowDataBound, gvwPendingOrders.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim litOrderValue As Literal = DirectCast(e.Row.FindControl("litOrderValue"), Literal)
            Dim hidOrderCurrencyID As HiddenField = DirectCast(e.Row.FindControl("hidOrderCurrencyID"), HiddenField)

            Dim numOrderValue As Single = CSng(litOrderValue.Text)
            Dim srtOrderCurrencyID As Short = CShort(hidOrderCurrencyID.Value)

            'Format the Order Total Price base on the Gateway's Currency
            Try
                litOrderValue.Text = CurrenciesBLL.FormatCurrencyPrice(srtOrderCurrencyID, numOrderValue)
            Catch ex As Exception
                litOrderValue.Text = "? " & numOrderValue
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
    End Sub

    Protected Sub btnPendingSelectAll_Click(sender As Object, e As EventArgs) Handles btnPendingSelectAll.Click
        For Each rw As GridViewRow In gvwPendingOrders.Rows
            If rw.RowType = DataControlRowType.DataRow Then
                CType(rw.FindControl("chkSelect"), CheckBox).Checked = True
            End If
        Next
    End Sub
    Protected Sub btnPendingSelectNone_Click(sender As Object, e As EventArgs) Handles btnPendingSelectNone.Click
        For Each rw As GridViewRow In gvwPendingOrders.Rows
            If rw.RowType = DataControlRowType.DataRow Then
                CType(rw.FindControl("chkSelect"), CheckBox).Checked = False
            End If
        Next
    End Sub
    Protected Sub btnPendingSend_Click(sender As Object, e As EventArgs) Handles btnPendingSend.Click
        Dim strSelected As String = "", strMessage As String = "", intCounter As Integer = 0
        For Each rw As GridViewRow In gvwPendingOrders.Rows
            If rw.RowType = DataControlRowType.DataRow Then
                If CType(rw.FindControl("chkSelect"), CheckBox).Checked Then
                    gvwPendingOrders.SelectedIndex = rw.RowIndex
                    Dim intOrderID As Integer = gvwPendingOrders.SelectedDataKey.Value
                    'strSelected += gvwPendingOrders.SelectedDataKey.Value & ","
                    If Not LinnworksServices._CreateNewLinnowrksOrder(intOrderID, litToken.Text, strMessage) Then
                        _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage & " <br/>The process will be stopped.")
                        Exit For
                    End If
                    intCounter += 1
                End If
            End If
        Next
        If intCounter > 0 Then
            CType(Me.Master, Skins_Admin_Template).DataUpdated()
            LoadPendingOrders()
            LoadSentOrders()
            SyncronizeAllStock()
        End If
        ' _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.Information, "Selected Orders:" & strSelected)
    End Sub

    Protected Sub btnStockSelectAll_Click(sender As Object, e As EventArgs) Handles btnStockSelectAll.Click
        For Each rw As GridViewRow In gvwStock.Rows
            If rw.RowType = DataControlRowType.DataRow Then
                CType(rw.FindControl("chkSelect"), CheckBox).Checked = True
            End If
        Next
    End Sub
    Protected Sub btnStockSelectNone_Click(sender As Object, e As EventArgs) Handles btnStockSelectNone.Click
        For Each rw As GridViewRow In gvwStock.Rows
            If rw.RowType = DataControlRowType.DataRow Then
                CType(rw.FindControl("chkSelect"), CheckBox).Checked = False
            End If
        Next
    End Sub
    Protected Sub btnStockSynchronize_Click(sender As Object, e As EventArgs) Handles btnStockSynchronize.Click
        Using dtStockLevels As New DataTable
            dtStockLevels.Columns.Add(New DataColumn("VersionCode", Type.GetType("System.String")))
            dtStockLevels.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Single")))
            dtStockLevels.Columns.Add(New DataColumn("WarnLevel", Type.GetType("System.Single")))
            Dim strSelected As String = ""
            For Each rw As GridViewRow In gvwStock.Rows
                If rw.RowType = DataControlRowType.DataRow Then
                    If CType(rw.FindControl("chkSelect"), CheckBox).Checked Then
                        'strSelected += rw.Cells(1).Text & ","
                        dtStockLevels.Rows.Add(rw.Cells(1).Text, CInt(rw.Cells(6).Text), DBNull.Value)
                    End If
                End If
            Next
            Dim strMessage As String = Nothing
            If VersionsBLL._UpdateVersionStockLevelByCode(dtStockLevels, strMessage) Then
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
            Else
                _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        End Using
        '_UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.Information, strSelected)
    End Sub
    Sub SyncronizeAllStock()
        Using dtStockLevels As New DataTable
            dtStockLevels.Columns.Add(New DataColumn("VersionCode", Type.GetType("System.String")))
            dtStockLevels.Columns.Add(New DataColumn("StockQty", Type.GetType("System.Single")))
            dtStockLevels.Columns.Add(New DataColumn("WarnLevel", Type.GetType("System.Single")))

            For Each rw As GridViewRow In gvwStock.Rows
                dtStockLevels.Rows.Add(rw.Cells(1).Text, CInt(rw.Cells(6).Text), DBNull.Value)
            Next

            Dim strMessage As String = Nothing
            If VersionsBLL._UpdateVersionStockLevelByCode(dtStockLevels, strMessage) Then
                CType(Me.Master, Skins_Admin_Template).DataUpdated()
            Else
                _UC_PopupMsg.ShowConfirmation(CkartrisEnumerations.MESSAGE_TYPE.ErrorMessage, strMessage)
            End If
        End Using
    End Sub
    
End Class
