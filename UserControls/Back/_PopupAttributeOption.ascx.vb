Imports CkartrisEnumerations
Partial Class UserControls_Custom_Back_PopupAttributeOption
    Inherits System.Web.UI.UserControl
    ''' <summary>
    ''' raised when the user click "yes" to confirm the operation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Confirmed()

    ''' <summary>
    ''' raised when the user click "no" to decline the operation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event Cancelled()

    ''' <summary>
    ''' The attribute Option that we are linking to
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property AttributeOptionId As Integer
        Get
            If IsNothing(ViewState("AttributeOptionId")) Then
                Return 0
            Else
                Return CInt(ViewState("AttributeOptionId"))
            End If
        End Get
        Set(value As Integer)
            ViewState("AttributeOptionId") = value
        End Set
    End Property

    ''' <summary>
    ''' The option group option that we are linking to
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property OptionGroupOptionID As Integer
        Get
            If IsNothing(ViewState("OptionGroupOptionID")) Then
                Return 0
            Else
                Return CInt(ViewState("OptionGroupOptionID"))
            End If
        End Get
        Set(value As Integer)
            ViewState("OptionGroupOptionID") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)

        If Not IsPostBack Then
            lblError.Text = ""
        End If
    End Sub

    Public Sub ShowAttributeOptions()
        If OptionGroupOptionID > 0 Then
            litOptionDetails.Text = OptionGroupOptionID.ToString

            ' Load by Option group Option ID
            LoadAttributeOptionsGridview(OptionGroupOptionID)

            LoadAttributesDropdown()

            mvViews.SetActiveView(viewAttributesForOption)
            popExtender.Show()
        ElseIf AttributeOptionId > 0 Then
            ' Load by Attribute Option ID
            litAttributeDetails.Text = AttributeOptionId.ToString

            LoadOptionGroupOptionsGridview(AttributeOptionId)

            LoadOptionGroupsDropdown()

            mvViews.SetActiveView(viewOptionsForAttribute)
            popExtender.Show()
        Else
            Exit Sub
        End If
    End Sub

    ''' <summary>
    ''' Populate drop down that lists all option groups.
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadOptionGroupsDropdown()
        ddlOptionGroups.DataSource = OptionsBLL._GetOptionGroups
        ddlOptionGroups.DataBind()

        If IsNumeric(ddlOptionGroups.SelectedValue) AndAlso ddlOptionGroups.SelectedValue > 0 Then
            LoadOptionGroupOptions(ddlOptionGroups.SelectedValue)
        End If
    End Sub

    Private Sub LoadOptionGroupOptions(ByVal OptionGroupId As Integer)
        Dim LangId As Integer = Nothing

        ' Load attributes dropdown.
        If IsNumeric(Session("Lang")) Then
            LangId = CInt(Session("Lang"))
        Else
            LangId = LanguagesBLL.GetDefaultLanguageID
        End If

        ddlOptionGroupOptions.DataSource = OptionsBLL._GetOptionsByGroupID(OptionGroupId, LangId)
        ddlOptionGroupOptions.DataBind()
    End Sub

    ''' <summary>
    ''' Populate drop down that lists all attributes
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub LoadAttributesDropdown()
        Dim LangId As Integer = Nothing

        ' Load attributes dropdown.
        If IsNumeric(Session("Lang")) Then
            LangId = CInt(Session("Lang"))
        Else
            LangId = LanguagesBLL.GetDefaultLanguageID
        End If

        ddlAttributes.DataSource = AttributesBLL._GetAttributesByLanguage(LangId)
        ddlAttributes.DataBind()

        If IsNumeric(ddlAttributes.SelectedValue) AndAlso ddlAttributes.SelectedValue > 0 Then
            LoadAttributeOptions(ddlAttributes.SelectedValue)
        End If
    End Sub

    ''' <summary>
    ''' Load all option group options associated with the attribute ID
    ''' </summary>
    ''' <param name="AttributeOptionID"></param>
    ''' <remarks></remarks>
    Private Sub LoadOptionGroupOptionsGridview(ByVal AttributeOptionID As Integer)
        Dim dtOptionGroupOptions = _GetOptionGroupOptionsByAttributeOptionID(AttributeOptionID)

        If Not IsNothing(dtOptionGroupOptions) AndAlso (dtOptionGroupOptions.Rows.Count > 0) Then
            Dim dtGridview As New DataTable     ' Formatted datatable for gridview
            dtGridview.Columns.Add("OptionGroupID", GetType(Integer))
            dtGridview.Columns.Add("OptionId", GetType(Integer))
            dtGridview.Columns.Add("OptionGroupName", GetType(String))
            dtGridview.Columns.Add("OptionName", GetType(String))
            dtGridview.Columns.Add("OptionGroupDetail", GetType(String))
            dtGridview.Columns.Add("OptionDetail", GetType(String))
            For Each dr As DataRow In dtOptionGroupOptions.Rows
                dtGridview.Rows.Add(CInt(dr("OPTG_ID")),
                                    CInt(dr("DOA_OptionID")),
                                    dr("OPTG_Name"),
                                    dr("OPT_Name"),
                                    String.Concat(dr("OPTG_ID"), ": ", dr("OPTG_Name")),
                                    String.Concat(dr("DOA_OptionID"), ": ", dr("OPT_Name")))
            Next

            gvOptions.DataSource = dtGridview
            gvOptions.DataBind()
        Else
            gvOptions.DataSource = Nothing
            gvOptions.DataBind()
        End If
    End Sub

    ''' <summary>
    ''' Load attribute options linked to an option group option
    ''' </summary>
    ''' <param name="OptionGroupOptionID"></param>
    ''' <remarks></remarks>
    Private Sub LoadAttributeOptionsGridview(ByVal OptionGroupOptionID As Integer)
        Dim dtAttributeOptions As DataTable = _GetAttributeOptionsByOptionGroupOptionID(OptionGroupOptionID)

        If Not IsNothing(dtAttributeOptions) AndAlso (dtAttributeOptions.Rows.Count > 0) Then
            Dim dtGridview As New DataTable     ' Formatted datatable for gridview
            dtGridview.Columns.Add("AttributeId", GetType(Integer))
            dtGridview.Columns.Add("AttributeOptionId", GetType(Integer))
            dtGridview.Columns.Add("AttributeName", GetType(String))
            dtGridview.Columns.Add("AttributeOptionName", GetType(String))
            dtGridview.Columns.Add("AttributeDetail", GetType(String))
            dtGridview.Columns.Add("AttributeOptionDetail", GetType(String))
            For Each dr As DataRow In dtAttributeOptions.Rows
                dtGridview.Rows.Add(CInt(dr("ATTRIB_ID")),
                                    CInt(dr("DOA_AttributeOptionID")),
                                    dr("ATTRIB_Name"),
                                    dr("ATTRIBO_Name"),
                                    String.Concat(dr("ATTRIB_ID"), ": ", dr("ATTRIB_Name")),
                                    String.Concat(dr("DOA_AttributeOptionID"), ": ", dr("ATTRIBO_Name")))
            Next

            gvAttributes.DataSource = dtGridview
            gvAttributes.DataBind()
        Else
            gvAttributes.DataSource = Nothing
            gvAttributes.DataBind()
        End If

    End Sub

    ''' <summary>
    ''' Get all attribute options associated with a given option group option
    ''' </summary>
    ''' <param name="OptionGroupOptionID"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function _GetAttributeOptionsByOptionGroupOptionID(ByVal OptionGroupOptionID As Integer) As DataTable
        _GetAttributeOptionsByOptionGroupOptionID = Nothing
        Dim strMsg As String = ""

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdStr As String = "spDeadlineTypeAttributeOptions_GetByOptions"
            Dim cmd As New SqlCommand(cmdStr, sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@OptionGroupOptions", OptionGroupOptionID)

            Try
                sqlConn.Open()
                Using sda As New SqlDataAdapter(cmd)
                    Dim dt As New DataTable()
                    sda.Fill(dt)
                    Return dt
                End Using
                lblError.Text = ""
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                lblError.Text = strMsg
            Finally
                sqlConn.Close()
                cmd.Dispose()
            End Try

        End Using
    End Function

    ''' <summary>
    ''' Get all option group options associated with a given attribute option
    ''' </summary>
    ''' <param name="AttributeOptionID"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function _GetOptionGroupOptionsByAttributeOptionID(ByVal AttributeOptionID As Integer) As DataTable
        _GetOptionGroupOptionsByAttributeOptionID = Nothing
        Dim strMsg As String = ""

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdStr As String = "spDeadlineTypeOptionGroupOptions_GetByAttributeOptions"
            Dim cmd As New SqlCommand(cmdStr, sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@AttributeOptions", AttributeOptionID)

            Try
                sqlConn.Open()
                Using sda As New SqlDataAdapter(cmd)
                    Dim dt As New DataTable()
                    sda.Fill(dt)
                    Return dt
                End Using
                lblError.Text = ""
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                lblError.Text = strMsg
            Finally
                sqlConn.Close()
                cmd.Dispose()
            End Try

        End Using
    End Function

    Private Sub _AddOptionAttribute(ByVal AttributeOptionID As Integer, ByVal OptionGroupOptionID As Integer)
        Dim strMsg As String = ""

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdStr As String = "_spDeadlineOptionAttribute_Add"
            Dim cmd As New SqlCommand(cmdStr, sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@AttributeOptionID", AttributeOptionID)
            cmd.Parameters.AddWithValue("@OptionGroupOptionID", OptionGroupOptionID)

            Try
                sqlConn.Open()
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                lblError.Text = strMsg
            Finally
                sqlConn.Close()
                cmd.Dispose()
            End Try

        End Using
    End Sub

    Private Sub _DeleteOptionAttribute(ByVal AttributeOptionID As Integer, ByVal OptionGroupOptionID As Integer)
        Dim strMsg As String = ""

        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)

            Dim cmdStr As String = "_spDeadlineOptionAttribute_Delete"
            Dim cmd As New SqlCommand(cmdStr, sqlConn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@AttributeOptionID", AttributeOptionID)
            cmd.Parameters.AddWithValue("@OptionGroupOptionID", OptionGroupOptionID)

            Try
                sqlConn.Open()
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                CkartrisFormatErrors.ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
                lblError.Text = strMsg
            Finally
                sqlConn.Close()
                cmd.Dispose()
            End Try

        End Using
    End Sub

    Protected Sub lnkYes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkYes.Click
        RaiseEvent Confirmed()
    End Sub

    Protected Sub lnkNo_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkNo.Click
        RaiseEvent Cancelled()
    End Sub

    Protected Sub ddlAttributes_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlAttributes.SelectedIndexChanged
        LoadAttributeOptions(ddlAttributes.SelectedValue)
    End Sub

    ''' <summary>
    ''' Cascading drop down
    ''' </summary>
    ''' <param name="AttributeId"></param>
    ''' <remarks></remarks>
    Private Sub LoadAttributeOptions(ByVal AttributeId As Integer)
        If AttributeId = 0 Then
            ddlAttributeOptions.Items.Clear()
        Else
            ddlAttributeOptions.DataSource = AttributesBLL.GetOptionsByAttributeID(AttributeId)

            ddlAttributeOptions.DataBind()
        End If
    End Sub

   

    Protected Sub btnAddAttributeOption_Click(sender As Object, e As EventArgs) Handles btnAddAttributeOption.Click
        lblError.Text = ""
        If IsNumeric(ddlAttributeOptions.SelectedValue) Then
            _AddOptionAttribute(CInt(ddlAttributeOptions.SelectedValue), OptionGroupOptionID)
            'Refresh
            ShowAttributeOptions()
        End If
    End Sub


    Protected Sub gvAttributes_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvAttributes.RowCommand
        Select Case e.CommandName.ToLower
            Case "delete"
                _DeleteOptionAttribute(CInt(e.CommandArgument), OptionGroupOptionID)
                'Refresh
                ShowAttributeOptions()
        End Select
    End Sub

    Protected Sub btnAddOptionGroupOption_Click(sender As Object, e As EventArgs) Handles btnAddOptionGroupOption.Click
        lblError.Text = ""
        If IsNumeric(ddlOptionGroupOptions.SelectedValue) Then
            _AddOptionAttribute(AttributeOptionId, CInt(ddlOptionGroupOptions.SelectedValue))
            'Refresh
            ShowAttributeOptions()
        End If
    End Sub

    Protected Sub ddlOptionGroups_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlOptionGroups.SelectedIndexChanged
        LoadOptionGroupOptions(ddlOptionGroups.SelectedValue)
    End Sub

    Protected Sub gvOptions_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvOptions.RowCommand
        Select Case e.CommandName.ToLower
            Case "delete"
                _DeleteOptionAttribute(AttributeOptionId, CInt(e.CommandArgument))
                'Refresh
                ShowAttributeOptions()
        End Select
    End Sub

    Protected Sub gvAttributes_RowDeleting(sender As Object, e As GridViewDeleteEventArgs) Handles gvAttributes.RowDeleting
        ' Have to manually trigger in this method or else gridview does not update after a delete 
        gvAttributes.DataBind()
    End Sub


    Protected Sub gvOptions_RowDeleting(sender As Object, e As GridViewDeleteEventArgs) Handles gvOptions.RowDeleting
        ' Have to manually trigger in this method or else gridview does not update after a delete 
        gvOptions.DataBind()
    End Sub
End Class
