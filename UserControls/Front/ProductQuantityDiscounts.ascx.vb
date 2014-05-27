﻿'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

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

''' <summary>
''' Used in the ProductView.ascx
''' </summary>
''' <remarks>By Paul</remarks>
Partial Class ProductQuantityDiscounts
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Private _LanguageID As Short

    Public ReadOnly Property ProductID() As Integer
        Get
            Return _ProductID
        End Get
    End Property

    Public ReadOnly Property LanguageID() As Integer
        Get
            Return _LanguageID
        End Get
    End Property

    ''' <summary>
    ''' Loads/shows the quantity discounts
    ''' </summary>
    ''' <param name="pProductID"></param>
    ''' <param name="pLanguageID"></param>
    ''' <remarks>By Paul</remarks>
    Public Sub LoadProductQuantityDiscounts(ByVal pProductID As Integer, ByVal pLanguageID As Short)
        _ProductID = pProductID
        _LanguageID = pLanguageID

        If Not Page.IsPostBack Then
            CheckForQuantityDiscount()
        End If
    End Sub

    Protected Sub CheckForQuantityDiscount()
        Dim tblQuantityDiscount As DataTable = VersionsBLL.GetQuantityDiscountByProduct(ProductID, Session("LANG"))
        If tblQuantityDiscount.Rows.Count > 0 Then
            Dim tblVersions As New DataTable
            tblVersions.Columns.Add(New DataColumn("VersionName", Type.GetType("System.String")))
            tblVersions.Columns.Add(New DataColumn("VersionCode", Type.GetType("System.String")))
            tblVersions.Columns.Add(New DataColumn("VersionID", Type.GetType("System.Int32")))
            Dim blnVersionExist As Boolean
            For Each drwDiscount As DataRow In tblQuantityDiscount.Rows
                blnVersionExist = False
                For Each v_row As DataRow In tblVersions.Rows
                    If v_row("VersionName") = drwDiscount("V_Name") Then blnVersionExist = True : Exit For
                Next
                If Not blnVersionExist Then tblVersions.Rows.Add(drwDiscount("V_Name"), drwDiscount("V_CodeNumber"), drwDiscount("V_ID"))
            Next
            rptQuantityDiscount.DataSource = tblVersions
            rptQuantityDiscount.DataBind()
        Else
            'Hide this control, we can use this to hide
            'the tab too by checking visibility of this
            'control in the ProductView.ascx control
            Me.Visible = False
        End If
    End Sub

    Protected Sub rptQuantityDiscount_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptQuantityDiscount.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then

            'We need customer ID because we want to hide quantity
            'discounts where price is higher than the customer group
            'pricing (and hence the lower customer group price will
            'be what is actually charged)
            Dim numCustomerID As Integer = 0
            If Context.User.Identity.IsAuthenticated Then
                Try
                    numCustomerID = DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID
                Catch ex As Exception
                    FormsAuthentication.SignOut()
                    numCustomerID = 0
                End Try
            Else
                numCustomerID = 0
            End If

            'What version is this?
            Dim numVersionID As Integer = CType(e.Item.FindControl("hidVersionID"), HiddenField).Value

            'Get the customer group price for this version
            Dim objBasket As New BasketBLL
            Dim numCustomerGroupPrice As Double = objBasket.GetCustomerGroupPriceForVersion(numCustomerID, numVersionID)

            Using tblQuantityDiscount As DataTable = VersionsBLL.GetQuantityDiscountByProduct(ProductID, Session("LANG"))
                Dim strVersionCode As String = CType(e.Item.FindControl("litVersionCode_Hidden"), Literal).Text

                Dim drwDiscount() As DataRow = tblQuantityDiscount.Select("V_CodeNumber='" & strVersionCode & "'")
                Using tblDiscounts As New DataTable
                    tblDiscounts.Columns.Add(New DataColumn("Quantity", Type.GetType("System.String")))
                    tblDiscounts.Columns.Add(New DataColumn("Price", Type.GetType("System.String")))
                    For i As Integer = 0 To drwDiscount.Length - 1
                        Dim numPrice As Single = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), CDbl(FixNullFromDB(drwDiscount(i)("QD_Price"))))

                        'If the numPrice from quantity discounts is higher than the 
                        'customer group price, we use the lower customer group price
                        'instead
                        If numPrice > numCustomerGroupPrice Then numPrice = numCustomerGroupPrice

                        'Format and add the price
                        tblDiscounts.Rows.Add(CStr(drwDiscount(i)("QD_Quantity")) & "+", _
                                CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), numPrice))
                    Next
                    CType(e.Item.FindControl("rptVersionsDiscount"), Repeater).DataSource = tblDiscounts
                    CType(e.Item.FindControl("rptVersionsDiscount"), Repeater).DataBind()
                End Using
            End Using
        End If
    End Sub

End Class
