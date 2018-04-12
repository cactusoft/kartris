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
Imports CkartrisFormatErrors
Imports CkartrisEnumerations
Partial Class _ItemSorter
    Inherits System.Web.UI.UserControl

    Dim c_tblImages As New DataTable
    Dim c_FolderPath As String

    Public Event ItemRemoved()

    Public Event NeedCategoryRefresh()

    Public Property FolderPath() As String
        Get
            Return c_FolderPath
        End Get
        Set(ByVal value As String)
            c_FolderPath = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
    End Sub

    ''' <summary>
    ''' Clear items
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub ClearItems()
        lbxImagesOrder.Items.Clear()

        ReorderImages()
    End Sub

    ''' <summary>
    ''' Return number of items
    ''' </summary>
    ''' <returns>No of items count</returns>
    ''' <remarks></remarks>
    Public Function NoOfItems() As Integer
        Return ajxReorder.Items.Count
    End Function

    ''' <summary>
    ''' Loads items into sorter
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub LoadItemsInSorter()
        If Not Page.IsPostBack Or lbxImagesOrder.Items.Count = 0 Then
            c_tblImages.Clear()
            c_tblImages.Columns.Clear()
            c_tblImages.Columns.Add(New DataColumn("No"))
            c_tblImages.Columns.Add(New DataColumn("ImageURL"))
            c_tblImages.Columns.Add(New DataColumn("ImageName"))
            c_tblImages.Columns.Add(New DataColumn("LastModified"))
            c_tblImages.Columns.Add(New DataColumn("ImageSize"))

            Dim dirImages As New DirectoryInfo(Server.MapPath(c_FolderPath))
            Dim fleImage() As FileInfo
            If Not dirImages.Exists() Then Exit Sub
            fleImage = dirImages.GetFiles()
            Dim strImgPath As String = "", strImgName As String = "", _
                strImgModified As String = "", strImgSize As String = ""
            For i As Integer = 0 To fleImage.GetUpperBound(0)
                strImgPath = c_FolderPath & fleImage(i).Name '& "?nocache=" & Now.Hour & Now.Minute & Now.Second
                strImgName = fleImage(i).Name
                strImgModified = fleImage(i).LastWriteTime.ToString()
                strImgSize = CStr(fleImage(i).Length() / 1000) & " KB"
                c_tblImages.Rows.Add(i, strImgPath, strImgName, strImgModified, strImgSize)
                lbxImagesOrder.Items.Add(fleImage(i).Name)
            Next
            ajxReorder.DataSource = c_tblImages
            ajxReorder.DataBind()
            rptImages.DataSource = c_tblImages
            rptImages.DataBind()

            ShowHideUpDownArrows()
        End If
    End Sub

    ''' <summary>
    ''' Handles change of sort order
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub ajxReorder_ItemReorder(ByVal sender As Object, ByVal e As AjaxControlToolkit.ReorderListItemReorderEventArgs) Handles ajxReorder.ItemReorder
        Dim strOldText As String = lbxImagesOrder.Items(e.OldIndex).Text

        If e.NewIndex < e.OldIndex Then  '' Move Down To Up
            For i As Integer = e.OldIndex To e.NewIndex + 1 Step -1
                lbxImagesOrder.Items(i).Text = lbxImagesOrder.Items(i - 1).Text
            Next
            lbxImagesOrder.Items(e.NewIndex).Text = strOldText
        Else    '' Move Up To Down
            For i As Integer = e.OldIndex To e.NewIndex - 1
                lbxImagesOrder.Items(i).Text = lbxImagesOrder.Items(i + 1).Text
            Next
            lbxImagesOrder.Items(e.NewIndex).Text = strOldText
        End If

        RenameItems()
        ReorderImages()
    End Sub

    ''' <summary>
    ''' Renames items which is used to sort them
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub RenameItems()
        'Use the coupon code generator to create random string part to include in file names
        Dim strRandomString As String = CouponsBLL._GenerateNewCouponCode()
        Dim strBaseName As String = ""
        Dim strName As String = ""
        For i As Byte = 0 To lbxImagesOrder.Items.Count - 1
            If i = 0 Then
                strBaseName = "temp-" & lbxImagesOrder.Items(i).Text
                If strBaseName.Contains("_") Then
                    'This was uploaded via Kartris, should have ordinal
                    'number part at end after an underscore
                    strBaseName = Left(strBaseName, strBaseName.IndexOf("_") + 1)
                Else
                    'This could be from a CactuShop or spreadsheet upload
                    'using the Data Tool
                    strBaseName = Left(strBaseName, strBaseName.IndexOf(".")) & "_"
                End If
            End If
            strName = strBaseName
            If i < 9 Then strName += "0"
            strName += (i + 1) & "_" & strRandomString & Right(lbxImagesOrder.Items(i).Text, 4)
            File.Copy(Server.MapPath(c_FolderPath & lbxImagesOrder.Items(i).Text),
                      Server.MapPath(c_FolderPath & strName))
        Next

        Dim dirInfo As New DirectoryInfo(Server.MapPath(c_FolderPath))
        Dim fleImage() As FileInfo
        fleImage = dirInfo.GetFiles()
        lbxImagesOrder.Items.Clear()
        For i As Integer = 0 To fleImage.GetUpperBound(0)
            If Not fleImage(i).Name.StartsWith("temp-") Then
                File.SetAttributes(Server.MapPath(c_FolderPath & fleImage(i).Name), FileAttributes.Normal)
                File.Delete(Server.MapPath(c_FolderPath & fleImage(i).Name))
            End If
        Next

        For i As Integer = 0 To fleImage.GetUpperBound(0)
            If fleImage(i).Name.StartsWith("temp-") Then
                File.Move(Server.MapPath(c_FolderPath & fleImage(i).Name), Server.MapPath(c_FolderPath & fleImage(i).Name.Replace("temp-", "")))
                lbxImagesOrder.Items.Add(fleImage(i).Name.Replace("temp-", ""))
            End If
        Next

    End Sub

    ''' <summary>
    ''' Add a new item to sorter
    ''' </summary>
    ''' <remarks></remarks>
    Public Sub AddNewItem(ByVal pImgName As String)
        lbxImagesOrder.Items.Add(pImgName)
        ReorderImages()
    End Sub

    ''' <summary>
    ''' Change sort order
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub ReorderImages()

        If Not Directory.Exists(Server.MapPath(c_FolderPath)) Then Return

        c_tblImages.Clear()
        c_tblImages.Columns.Clear()
        c_tblImages.Columns.Add(New DataColumn("No"))
        c_tblImages.Columns.Add(New DataColumn("ImageURL"))
        c_tblImages.Columns.Add(New DataColumn("ImageName"))
        c_tblImages.Columns.Add(New DataColumn("LastModified"))
        c_tblImages.Columns.Add(New DataColumn("ImageSize"))

        Dim dirImages As New DirectoryInfo(Server.MapPath(c_FolderPath))
        Dim fleImage() As FileInfo
        fleImage = dirImages.GetFiles()
        Dim strImgPath As String = "", strImgName As String = "", strImgModified As String = "", strImgSize As String = ""
        For Each Itm As ListItem In lbxImagesOrder.Items
            For i As Integer = 0 To fleImage.GetUpperBound(0)
                If Itm.Text = fleImage(i).Name Then
                    strImgPath = c_FolderPath & fleImage(i).Name '& "?nocache=" & Now.Hour & Now.Minute & Now.Second
                    strImgName = fleImage(i).Name
                    strImgModified = fleImage(i).LastWriteTime.ToString()
                    strImgSize = CStr(fleImage(i).Length() / 1000) & " KB"
                    c_tblImages.Rows.Add(i, strImgPath, strImgName, strImgModified, strImgSize)
                    Exit For
                End If
            Next
        Next

        ajxReorder.DataSource = c_tblImages
        ajxReorder.DataBind()
        rptImages.DataSource = c_tblImages
        rptImages.DataBind()

        ShowHideUpDownArrows()
       
    End Sub

    ''' <summary>
    ''' Handles commands on sort buttons (Remove, MoveUp, MoveDown)
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub rptImages_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles rptImages.ItemCommand

        If e.CommandName = "Remove" Then
            Dim strImageName As String = CType(e.Item.FindControl("litImgName"), Literal).Text
            litImageNameToRemove.Text = strImageName
            imgToRemove.ImageUrl = CType(e.Item.FindControl("litImgURL"), Literal).Text
            litImgName3.Text = imgToRemove.ImageUrl.ToString
            popExtender.Show()
        End If
        If e.CommandName = "MoveUp" Then
            Dim strOldText As String = lbxImagesOrder.Items(e.Item.ItemIndex).Text
            lbxImagesOrder.Items(e.Item.ItemIndex).Text = lbxImagesOrder.Items(e.Item.ItemIndex - 1).Text
            lbxImagesOrder.Items(e.Item.ItemIndex - 1).Text = strOldText
            RenameItems()
            ReorderImages()
        End If
        If e.CommandName = "MoveDown" Then
            Dim strOldText As String = lbxImagesOrder.Items(e.Item.ItemIndex).Text
            lbxImagesOrder.Items(e.Item.ItemIndex).Text = lbxImagesOrder.Items(e.Item.ItemIndex + 1).Text
            lbxImagesOrder.Items(e.Item.ItemIndex + 1).Text = strOldText
            RenameItems()
            ReorderImages()
        End If
        RaiseEvent NeedCategoryRefresh()
    End Sub

    ''' <summary>
    ''' Click YES to confirm delete
    ''' </summary>
    ''' <remarks></remarks>
    Protected Sub lnkYes_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkYes.Click
        Try
            Dim strFileName As String = ""
            strFileName = imgToRemove.ImageUrl
            If Not File.Exists(Server.MapPath(strFileName)) Then Return
            File.SetAttributes(Server.MapPath(strFileName), FileAttributes.Normal)
            File.Delete(Server.MapPath(strFileName))
            lbxImagesOrder.Items.Remove(litImageNameToRemove.Text)
            ReorderImages()
            RaiseEvent ItemRemoved()
        Catch ex As Exception
            Dim strMessage As String = ""
            ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMessage)
            _UC_PopupMsg.ShowConfirmation(MESSAGE_TYPE.ErrorMessage, strMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Activate/deactivate UP/DOWN arrows by items
    ''' </summary>
    ''' <remarks>Top item has up button disabled, etc.</remarks>
    Private Sub ShowHideUpDownArrows()
        Try
            CType(rptImages.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).Enabled = False
            CType(rptImages.Items(0).FindControl("lnkBtnMoveUp"), LinkButton).CssClass &= " triggerswitch_disabled"
            CType(rptImages.Items(c_tblImages.Rows.Count - 1).FindControl("lnkBtnMoveDown"), LinkButton).Enabled = False
            CType(rptImages.Items(c_tblImages.Rows.Count - 1).FindControl("lnkBtnMoveDown"), LinkButton).CssClass &= " triggerswitch_disabled"
        Catch ex As Exception
        End Try
    End Sub

End Class
