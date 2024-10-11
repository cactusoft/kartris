'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

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
''' This control contains the dropdown, textbox or hidden field for quantity
''' which is added to the basket. For some display types, a button can be
''' displayed. For options and dropdown versions, the button is hidden, as
''' a separate add-to-basket button is used on those version display methods
''' (because they have add button specific code to fire)
''' </summary>
Partial Class UserControls_General_AddToBasket
    Inherits System.Web.UI.UserControl

    'This user control contains the version ID
    'which we need when add to basket button is
    'pushed, and also a boolean to specify
    'whether it should display with a button or
    'not'
    Private c_numVersionID As Long
    Private c_numProductID As Long
    Private c_blnHasAddButton As Boolean
    Private c_blnCanCustomize As Boolean
    Private c_strSelectorType As String
    Private c_ItemsQuantity As Single
    Private c_ItemEditQty As Single
    Private c_ItemEditVersionID As Integer
    Private c_UnitSize As String

    Public Property VersionID() As Long
        Get
            Return c_numVersionID
        End Get
        Set(ByVal value As Long)
            c_numVersionID = value
            litVersionID.Text = c_numVersionID
        End Set
    End Property

    Public Property HasAddButton() As Boolean
        Get
            Return c_blnHasAddButton
        End Get
        Set(ByVal value As Boolean)
            c_blnHasAddButton = value
            btnAdd.Visible = c_blnHasAddButton
        End Set
    End Property


    Public Property CanCustomize() As Boolean
        Get
            Return c_blnCanCustomize
        End Get
        Set(ByVal value As Boolean)
            c_blnCanCustomize = value
            If c_blnCanCustomize = True Then
                btnAdd.OnClientClick = ""
            End If
        End Set
    End Property

    'Dropdown, textbox or just a button
    Public Property SelectorType() As String
        Get
            Return c_strSelectorType
        End Get
        Set(ByVal value As String)
            GetSelectorType(value)
        End Set
    End Property

    Public Function GetSelectorType(ByVal strSelectorType As String) As String
        If strSelectorType <> "" Then
            c_strSelectorType = strSelectorType
        Else
            'Try to set to the K:product.addtorbasketqty set at product level
            Dim objVersionsBLL As New VersionsBLL
            Dim objObjectConfigBLL As New ObjectConfigBLL
            c_strSelectorType = LCase(FixNullFromDB(objObjectConfigBLL.GetValue("K:product.addtobasketqty", objVersionsBLL.GetProductID_s(c_numVersionID))))
            If c_strSelectorType Is Nothing Then c_strSelectorType = ""

            'No per-product value set, default to global config setting frontend.basket.addtobasketdisplay
            If c_strSelectorType = "" Then c_strSelectorType = KartSettingsManager.GetKartConfig("frontend.basket.addtobasketdisplay")
        End If
        Return c_strSelectorType
    End Function

    'Read the item quantity from the dropdown
    Public ReadOnly Property ItemsQuantity() As Single
        Get
            Dim numItemsQuantity As Single = 1

            'Ok, this is a cheat... we don't know type of selector
            'at this stage, so how to know whether to check the
            'dropdown or textbox for the qty? What we do is check
            'which is highest value, then use that. This gives us
            'a 1 as default, or higher number if either textbox or
            'dropdown has a number in. It also means for blank or
            'non-valid textbox input, we output 1.

            If IsNumeric(ddlItemsQuantity.SelectedValue) Then
                numItemsQuantity = ddlItemsQuantity.SelectedValue
            Else
                Try
                    numItemsQuantity = txtItemsQuantity.Text
                Catch ex As Exception
                    numItemsQuantity = 1
                End Try

            End If

            Return numItemsQuantity
        End Get

    End Property

    Public Property ItemEditQty() As Double
        Get
            Return c_ItemEditQty
        End Get
        Set(ByVal value As Double)
            c_ItemEditQty = value
        End Set
    End Property

    Public Property ItemEditVersionID() As Integer
        Get
            Return c_ItemEditVersionID
        End Get
        Set(ByVal value As Integer)
            c_ItemEditVersionID = value
        End Set
    End Property

    Public ReadOnly Property UnitSize() As String
        Get
            Return GetUnitSize()
        End Get
    End Property

    Public Function GetUnitSize() As String
        'For some items, using ProductID works. Some like multiple versions seem not
        'to pass this well, so better to use the VersionID and then lookup parent product from that
        Dim numProductID As Long
        numProductID = c_numProductID
        Dim objVersionsBLL As New VersionsBLL
        If numProductID = 0 Then
            Try
                numProductID = objVersionsBLL.GetProductID_s(litVersionID.Text)
            Catch ex As Exception
                'Hope we never land here
            End Try
        End If

        'Unit size should be checked if the quantity control is "textbox" => qty entered by user
        Dim objObjectConfigBLL As New ObjectConfigBLL
        c_UnitSize = FixNullFromDB(objObjectConfigBLL.GetValue("K:product.unitsize", numProductID))
        If c_UnitSize Is Nothing Then c_UnitSize = ""
        c_UnitSize = Replace(c_UnitSize, ",", ".") 'Will use the "." instead of "," (just in case wrongly typed)
        If Not IsNumeric(c_UnitSize) Then c_UnitSize = "1" 'Unit size default value is 1
        Return c_UnitSize
    End Function

    'Handles the 'add' button being clicked.
    'Remember this does not happen for options
    'or version dropdowns, as these have their
    'own add buttons and click handling in
    'ProductVersions.aspx
    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAdd.Click

        Dim strUnitSize As String = GetUnitSize()
        Dim numQuantity As Single = Me.ItemsQuantity
        Dim objMiniBasket As Object = Page.Master.FindControl("UC_MiniBasket")
        Dim numMod As Decimal = SafeModulus(numQuantity, strUnitSize)
        Dim objVersionsBLL As New VersionsBLL

        If numMod <> 0D Then
            '' wrong quantity - quantity should be a multiplies of unit size
            objMiniBasket.ShowPopupMini(GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors"),
                        Replace(GetGlobalResourceObject("ObjectConfig", "ContentText_OrderMultiplesOfUnitsize"), "[unitsize]", strUnitSize))
        Else
            'qty ok, matches unitsize allowed
            'Trace.Warn("Quantity: " & numQuantity)

            Dim numBasketItemID As Long = 0, numEditVersionID As Long = 0
            Dim objObjectConfigBLL As New ObjectConfigBLL
            Dim strAddToBasketQtyCFG As String = FixNullFromDB(objObjectConfigBLL.GetValue("K:product.addtobasketqty", objVersionsBLL.GetProductID_s(c_numVersionID)))
            If strAddToBasketQtyCFG Is Nothing Then strAddToBasketQtyCFG = ""
            If Session("BasketItemInfo") & "" <> "" AndAlso LCase(strAddToBasketQtyCFG) = "dropdown" Then
                Dim arrBasketItemInfo() As String = Split(Session("BasketItemInfo") & "", ";")
                numBasketItemID = arrBasketItemInfo(0)
                numEditVersionID = arrBasketItemInfo(1)
            End If

            If CLng(litVersionID.Text) <> numEditVersionID Then numBasketItemID = 0

            objMiniBasket.ShowCustomText(CLng(litVersionID.Text), numQuantity, "", numBasketItemID)

            Session("AddItemVersionID") = litVersionID.Text
        End If

        'v2.9010 Autosave basket
        Try
            BasketBLL.AutosaveBasket(DirectCast(Page, PageBaseClass).CurrentLoggedUser.ID)
        Catch ex As Exception
            'User not logged in
        End Try

    End Sub

    Private Sub LoadAddItemToBasket()
        Dim strUnitSize As String = GetUnitSize()
        Dim strMinimumAllowedQty As String = "1"
        Dim objVersionsBLL As New VersionsBLL
        Dim objObjectConfigBLL As New ObjectConfigBLL

        'If nothing specified, set selector type based
        'on config setting.
        Dim strAddToBasketQtyCFG As String = FixNullFromDB(objObjectConfigBLL.GetValue("K:product.addtobasketqty", objVersionsBLL.GetProductID_s(c_numVersionID)))
        If strAddToBasketQtyCFG Is Nothing Then strAddToBasketQtyCFG = ""
        c_strSelectorType = GetSelectorType(strAddToBasketQtyCFG)

        'Create onclientclick event to launch
        'the 'add to basket' popup. This way it
        'appears instantly when the button is
        'clicked, while the adding process can
        'happen in the background.
        If IsNumeric(KartSettingsManager.GetKartConfig("frontend.basket.behaviour")) Then
            'If the item is customizable, we don't want to launch
            'the 'add to basket' popup, but revert to the 
            'customization popup.
            If CanCustomize = False Then
                btnAdd.OnClientClick = "ShowAddToBasketPopup(" & KartSettingsManager.GetKartConfig("frontend.basket.behaviour") * 1000 & ")"
            End If
        End If

        'Need to know if the decimal quantity is allowed or not
        If Math.Abs(CSng(strUnitSize) Mod 1) > 0.0F Then
            'UnitSize is decimal
            If CSng(strUnitSize) > 1 Then strMinimumAllowedQty = strUnitSize
            strMinimumAllowedQty = strUnitSize
            'we need to exclude the "." if the unit size is decimal, so to accept both (numbers & ".")
            filQuantity.FilterType = AjaxControlToolkit.FilterTypes.Numbers Or AjaxControlToolkit.FilterTypes.Custom
            filQuantity.ValidChars = "."
        Else
            'UnitSize is integer
            If CInt(strUnitSize) > 1 Then strMinimumAllowedQty = CInt(strUnitSize)
        End If

        'Set quantity selector type
        Select Case c_strSelectorType
            Case "textbox"
                txtItemsQuantity.Text = strMinimumAllowedQty
                txtItemsQuantity.Visible = True
                ddlItemsQuantity.Visible = False

            Case "none"
                'No field to input quantity next to 'add' button
                '(just adds a single item when button pushed, best
                'for sites where there are only single items for sale, or large
                'value items people are unlikely to order in quantity)
                txtItemsQuantity.Visible = False
                ddlItemsQuantity.Visible = False
                txtItemsQuantity.Text = strMinimumAllowedQty

            Case Else
                'Defaults the selector to dropdown if not specified explicitly.
                Dim numCounter As Integer
                Dim bitValue As Byte = 1
                Try
                    bitValue = CByte(ddlItemsQuantity.Text)
                Catch ex As Exception
                End Try
                ddlItemsQuantity.Items.Clear()

                'We want number of entries as in the config setting. However,
                'if the item has a unitsize set, we want to reflect that. So
                'we should multiply everything by unitsize.
                For numCounter = 1 To CInt(KartSettingsManager.GetKartConfig("frontend.basket.addtobasketdropdown.max"))
                    ddlItemsQuantity.Items.Add((numCounter * CSng(strUnitSize)).ToString)
                Next

                If c_numVersionID = c_ItemEditVersionID And c_ItemEditVersionID > 0 Then
                    btnAdd.Text = GetGlobalResourceObject("_Kartris", "FormButton_Update")
                    If Not IsPostBack Then
                        If numCounter < (c_ItemEditQty / CSng(strUnitSize)) Then
                            ddlItemsQuantity.Items.Add(c_ItemEditQty)
                            ddlItemsQuantity.SelectedValue = c_ItemEditQty
                        Else
                            ddlItemsQuantity.SelectedValue = c_ItemEditQty
                        End If
                    Else
                        ddlItemsQuantity.Text = bitValue
                    End If
                Else
                    btnAdd.Text = GetGlobalResourceObject("Products", "FormButton_Add")
                    If bitValue >= numCounter Then
                        ddlItemsQuantity.Items.Add(bitValue)
                        ddlItemsQuantity.SelectedValue = bitValue
                    End If
                    Try
                        ddlItemsQuantity.Text = bitValue
                    Catch ex As Exception
                        'oh dear
                    End Try
                End If
                txtItemsQuantity.Visible = False
                ddlItemsQuantity.Visible = True
        End Select
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Session("AddItemVersionID") = ""
        End If
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        LoadAddItemToBasket()
    End Sub

End Class
