'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

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

Partial Class Admin_Promotions
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = GetGlobalResourceObject("_Promotions", "PageTitle_Promotions") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        If Not Page.IsPostBack Then
            If KartSettingsManager.GetKartConfig("frontend.promotions.enabled") <> "y" Then
                litFeatureDisabled.Text = Replace( _
                    GetGlobalResourceObject("_Kartris", "ContentText_DisabledInFrontEnd"), "[name]", _
                    GetGlobalResourceObject("_Promotions", "PageTitle_Promotions"))
                phdFeatureDisabled.Visible = True
            Else
                phdFeatureDisabled.Visible = False
            End If
            ShowPromotionList()
        End If

        lnkBtnSave.ValidationGroup = LANG_ELEM_TABLE_TYPE.Promotions
    End Sub

    Private Sub ShowPromotionList()
        Using tblPromotions As New DataTable
            Dim tblPromotionDetails As New DataTable
            tblPromotionDetails = PromotionsBLL._GetData()

            If tblPromotionDetails.Rows.Count = 0 Then mvwPromotions.SetActiveView(viwNoItems) : Return
            mvwPromotions.SetActiveView(viwPromotionList)

            tblPromotions.Columns.Add(New DataColumn("PROM_ID", Type.GetType("System.Int32")))
            tblPromotions.Columns.Add(New DataColumn("PROM_Text", Type.GetType("System.String")))
            tblPromotions.Columns.Add(New DataColumn("PROM_Start", Type.GetType("System.DateTime")))
            tblPromotions.Columns.Add(New DataColumn("PROM_End", Type.GetType("System.DateTime")))
            tblPromotions.Columns.Add(New DataColumn("PROM_Live", Type.GetType("System.Boolean")))
            tblPromotions.Columns.Add(New DataColumn("PROM_OrderNo", Type.GetType("System.Int32")))
            tblPromotions.Columns.Add(New DataColumn("PROM_MaxQuantity", Type.GetType("System.Byte")))


            For Each row As DataRow In tblPromotionDetails.Rows
                tblPromotions.Rows.Add(CInt(row("PROM_ID")), GetPromotionText(CInt(row("PROM_ID"))), _
                                       CDate(row("PROM_StartDate")).ToString(), _
                                       CDate(row("PROM_EndDate")).ToString(), _
                                       CBool(row("PROM_Live")), FixNullFromDB(row("PROM_OrderByValue")), _
                                       FixNullFromDB(row("PROM_MaxQuantity")))
            Next

            gvwPromotions.DataSource = tblPromotions
            gvwPromotions.DataBind()
        End Using
    End Sub

    Private Function GetPromotionText(ByVal intPromotionID As Integer) As String
        Dim tblPromotionParts As New DataTable
        tblPromotionParts = PromotionsBLL._GetPartsByPromotion(intPromotionID, Session("_LANG"))

        Dim strBldrPromotionText As New StringBuilder("")
        Dim intTextCounter As Integer = 0

        For Each row As DataRow In tblPromotionParts.Rows

            Dim strText As String = row("PS_Text")
            Dim strStringID As String = row("PS_ID")
            Dim strValue As String = FixNullFromDB(row("PP_Value"))
            Dim strItemID As String = FixNullFromDB(row("PP_ItemID"))
            Dim strItemName As String = ""
            Dim strItemLink As String = ""

            If strText.Contains("[X]") Then
                strText = strText.Replace("[X]", row("PP_Value"))
            End If

            If strText.Contains("[C]") AndAlso strItemID <> "" Then
                strItemName = CategoriesBLL._GetNameByCategoryID(CInt(strItemID), Session("_LANG"))
                strItemLink = " <b><a href='_ModifyCategory.aspx?CategoryID=" & strItemID & "'>" & strItemName & "</a></b>"
                strText = strText.Replace("[C]", strItemLink)
            End If

            If strText.Contains("[P]") AndAlso strItemID <> "" Then
                strItemName = ProductsBLL._GetNameByProductID(CInt(strItemID), Session("_LANG"))
                strItemLink = " <b><a href='_ModifyProduct.aspx?ProductID=" & strItemID & "'>" & strItemName & "</a></b>"
                strText = strText.Replace("[P]", strItemLink)
            End If

            If strText.Contains("[V]") AndAlso strItemID <> "" Then
                Dim ProductID As Integer = VersionsBLL.GetProductID_s(CInt(strItemID))
                strItemName = VersionsBLL._GetNameByVersionID(CInt(strItemID), Session("_LANG"))
                strItemLink = " <b><a href='_ModifyProduct.aspx?ProductID=" & ProductID & "'>" & _
                    ProductsBLL._GetNameByProductID(ProductID, 1) & " (" & strItemName & ")</a></b>"
                strText = strText.Replace("[V]", strItemLink)
            End If

            If strText.Contains("[£]") Then
                strText = strText.Replace("[£]", CurrenciesBLL.CurrencySymbol(CurrenciesBLL.GetDefaultCurrency))
            End If

            intTextCounter += 1
            If intTextCounter > 1 Then
                strBldrPromotionText.Append(", ")
            End If
            strBldrPromotionText.Append(strText)
        Next
        Return strBldrPromotionText.ToString
    End Function

    Protected Sub gvwPromotions_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gvwPromotions.PageIndexChanging
        gvwPromotions.PageIndex = e.NewPageIndex
        ShowPromotionList()
    End Sub

    Protected Sub lnkBtnNewPromotion_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnNewPromotion.Click
        litPromotionID.Text = "0"
        _UC_EditPromotion.EditPromotion(GetPromotionID())

        StartUpdate()
    End Sub

    Protected Sub gvwPromotions_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvwPromotions.RowCommand
        If e.CommandName = "EditPromotion" Then
            gvwPromotions.SelectedIndex = e.CommandArgument Mod gvwPromotions.PageSize
            litPromotionID.Text = gvwPromotions.SelectedValue()
            _UC_EditPromotion.EditPromotion(GetPromotionID())

            StartUpdate()
        End If
    End Sub


    ''' <summary>
    ''' returns the promotion id (saved in a hidden control)
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPromotionID() As Integer
        If litPromotionID.Text <> "" Then
            Return CInt(litPromotionID.Text)
        End If
        Return 0
    End Function

    Protected Sub lnkBtnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnCancel.Click
        ShowPromotionList()
    End Sub

    Protected Sub lnkBtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSave.Click
        If _UC_EditPromotion.SaveChanges() Then

            ShowPromotionList()
            FinishUpdate()

            CType(Me.Master, Skins_Admin_Template).DataUpdated()
        End If
    End Sub

    Protected Sub gvwPromotions_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvwPromotions.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim strPromotionID As Integer = CType(e.Row.Cells(1).FindControl("litPromotionID"), Literal).Text
            If Directory.Exists(Server.MapPath("~/Images/Promotions/" & strPromotionID)) Then
                Dim dirInfo As New DirectoryInfo(Server.MapPath("~/Images/Promotions/" & strPromotionID))
                Dim fileImage() As FileInfo
                fileImage = dirInfo.GetFiles()
                If fileImage.Length > 0 Then
                    CType(e.Row.Cells(1).FindControl("imgPromotion"), Image).ImageUrl = _
                        "~/Images/Promotions/" & strPromotionID & "/" & fileImage(0).Name & "?nocache=" & Now.Hour & Now.Minute & Now.Second
                End If
            End If

            Dim strImagePath As String = CType(e.Row.Cells(1).FindControl("imgPromotion"), Image).ImageUrl
            If strImagePath Is Nothing OrElse strImagePath = "" Then
                CType(e.Row.Cells(1).FindControl("imgPromotion"), Image).ImageUrl = _
                    "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png"
            Else
                strImagePath = Left(strImagePath, strImagePath.IndexOf("?"))
                If Not File.Exists(Server.MapPath(strImagePath)) Then
                    CType(e.Row.Cells(1).FindControl("imgPromotion"), Image).ImageUrl = _
                    "~/Skins/" & CkartrisBLL.Skin(Session("LANG")) & "/Images/no_image_available.png"
                End If
            End If

        End If
    End Sub

    Protected Sub lnkBtnBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack.Click, lnkBtnCancel.Click
        FinishUpdate()
    End Sub

    Protected Sub _UC_EditPromotion_NeedCategoryRefresh() Handles _UC_EditPromotion.NeedCategoryRefresh
        CType(Me.Master, Skins_Admin_Template).LoadCategoryMenu()
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_EditPromotion.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
    End Sub

    Sub FinishUpdate()
        ShowPromotionList()
        phdViewPromotions.Visible = True
        phdEditPromotion.Visible = False
        updViewPromotion.Update()
        updEditPromotion.Update()
    End Sub
    Sub StartUpdate()
        phdViewPromotions.Visible = False
        phdEditPromotion.Visible = True
        updViewPromotion.Update()
        updEditPromotion.Update()
    End Sub
End Class