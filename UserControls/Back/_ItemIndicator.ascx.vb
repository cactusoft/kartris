'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisDataManipulation

Partial Class UserControls_Back_ItemIndicator

    Inherits System.Web.UI.UserControl

    Private _ItemType As String

    Public WriteOnly Property ItemType() As String
        Set(ByVal value As String)
            _ItemType = value
        End Set
    End Property

    Public Sub CheckProductStatus()
        Dim blnProductLive As Boolean = False, strProductType As String = "", numCustomerGroup As Short = 0
        Dim numLiveVersions As Integer = 0, numLiveCategories As Integer = 0
        Dim objVersionsBLL As New VersionsBLL
        Dim objProductsBLL As New ProductsBLL

        objProductsBLL._GetProductStatus(_GetProductID(), blnProductLive, strProductType,
                                      numLiveVersions, numLiveCategories, numCustomerGroup)
        bulList.Items.Clear()

        '(a) it is set to not live 
        If blnProductLive = False Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_ProductNotLive")))
        End If
        '(b) it has no valid versions
        If numLiveVersions = 0 Then
            If strProductType = "o" Then
                bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_ProductBaseVersionNotLive")))
            Else
                bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_NoVersions")))
            End If
        End If
        '(c) it is linked to a customer group 
        If FixNullFromDB(numCustomerGroup) <> 0 Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_BelongsToCustomerGroup")))
        End If
        '(d) none of the categories it belongs to are live.
        If numLiveCategories = 0 Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_NoParentCatsLive")))
        End If
        '(e) none of the options has been assigned to the product
        If strProductType = "o" Then
            Using tblOptions As New DataTable
                If objVersionsBLL.GetProductOptions(_GetProductID(), Session("_lang")).Rows.Count = 0 Then
                    bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_NoOptionsSelected")))
                End If
            End Using
        End If


        If bulList.Items.Count > 0 Then
            pnlMessage.Visible = True
            updIndicator.Update()
        Else
            pnlMessage.Visible = False
            updIndicator.Update()
        End If

    End Sub

    Sub CheckCategoryStatus()
        Dim blnCategoryLive As Boolean = False, numCustomerGroup As Short = 0
        Dim numLiveParents As Integer = 0
        Dim objCategoriesBLL As New CategoriesBLL
        objCategoriesBLL._GetCategoryStatus(_GetCategoryID(), blnCategoryLive, numLiveParents, numCustomerGroup)

        bulList.Items.Clear()

        '(a) it is set to not live 
        If blnCategoryLive = False Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_ProductNotLive")))
        End If
        '(b) it is linked to a customer group 
        If FixNullFromDB(numCustomerGroup) <> 0 Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_BelongsToCustomerGroup")))
        End If
        '(d) none of the categories it belongs to are live.
        If numLiveParents = 0 Then
            bulList.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_NoParentCatsLive")))
        End If

        If bulList.Items.Count > 0 Then
            pnlMessage.Visible = True
            updIndicator.Update()
        Else
            pnlMessage.Visible = False
            updIndicator.Update()
        End If
    End Sub

End Class
