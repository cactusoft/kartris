'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

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
''' <remarks>By Paul</remarks>
''' 
Partial Class UserControls_General_AddToBasket
    Inherits System.Web.UI.UserControl

    'This user control contains the version ID
    'which we need when add to basket button is
    'pushed, and also a boolean to specify
    'whether it should display with a button or
    'not'
    Private c_numVersionID As Long
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
            If value <> "" Then
                c_strSelectorType = value
            Else
                'Try to set to the K:product.addtorbasketqty set at product level
                c_strSelectorType = LCase(FixNullFromDB(ObjectConfigBLL.GetValue("K:product.addtobasketqty", VersionsBLL.GetProductID_s(c_numVersionID))))
                If c_strSelectorType Is Nothing Then c_strSelectorType = ""

                'No per-product value set, default to global config setting frontend.basket.addtobasketdisplay
                If c_strSelectorType = "" Then c_strSelectorType = KartSettingsManager.GetKartConfig("frontend.basket.addtobasketdisplay")
            End If
        End Set
    End Property

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
            '' check if there is (no value or invalid value)
            If String.IsNullOrEmpty(c_UnitSize) OrElse Not IsNumeric(c_UnitSize) Then
                '' Unit size default value is 1
                If String.IsNullOrEmpty(litVersionID.Text) OrElse Not IsNumeric(litVersionID.Text) Then Return "1"

                '' Unit size should be checked if the quantity control is "textbox" => qty entered by user
                c_UnitSize = FixNullFromDB(ObjectConfigBLL.GetValue("K:product.unitsize", CLng(VersionsBLL.GetProductID_s(CLng(litVersionID.Text)))))
                If c_UnitSize Is Nothing Then c_UnitSize = ""
                c_UnitSize = Replace(c_UnitSize, ",", ".") '' Will use the "." instead of "," (just in case wrongly typed)
                If Not IsNumeric(c_UnitSize) Then c_UnitSize = "1" '' Unit size default value is 1
            End If
            Return c_UnitSize
        End Get
    End Property

    'Handles the 'add' button being clicked.
    'Remember this does not happen for options
    'or version dropdowns, as these have their
    'own add buttons and click handling in
    'ProductVersions.aspx
    Public Event WrongQuantity(strTitle As String, strMessage As String)

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAdd.Click

        Dim strUnitSize As String = UnitSize
        Dim numQuantity As Single = Me.ItemsQuantity

        '' Check for wrong quantity
        Dim numNoOfDecimalPlacesForUnit As Integer = IIf(strUnitSize.Contains("."), Mid(strUnitSize, strUnitSize.IndexOf(".") + 2).Length, 0)
        Dim numNoOfDecimalPlacesForQty As Integer = IIf(CStr(numQuantity).Contains(".") AndAlso CLng(Mid(CStr(numQuantity), CStr(numQuantity).IndexOf(".") + 2)) <> 0, _
                                                        Mid(CStr(numQuantity), CStr(numQuantity).IndexOf(".") + 2).Length, _
                                                        0)
        Dim numMod As Integer = CInt(numQuantity * Math.Pow(10, numNoOfDecimalPlacesForQty)) Mod CInt(strUnitSize * Math.Pow(10, numNoOfDecimalPlacesForUnit))
        If numMod <> 0.0F OrElse numNoOfDecimalPlacesForQty > numNoOfDecimalPlacesForUnit Then
            '' wrong quantity - quantity should be a multiplies of unit size
            RaiseEvent WrongQuantity(GetGlobalResourceObject("Kartris", "ContentText_CorrectErrors"), _
               Replace(GetGlobalResourceObject("ObjectConfig", "ContentText_OrderMultiplesOfUnitsize"), "[unitsize]", strUnitSize))
        Else

            Trace.Warn("Quantity: " & numQuantity)

            Dim objMiniBasket As Object = Page.Master.FindControl("UC_MiniBasket")
            Dim numVersionID As Long, numBasketItemID As Long = 0, numEditVersionID As Long = 0
            Dim strAddToBasketQtyCFG As String = FixNullFromDB(ObjectConfigBLL.GetValue("K:product.addtobasketqty", VersionsBLL.GetProductID_s(c_numVersionID)))
            If strAddToBasketQtyCFG Is Nothing Then strAddToBasketQtyCFG = ""
            If Session("BasketItemInfo") & "" <> "" AndAlso LCase(strAddToBasketQtyCFG) = "dropdown" Then
                Dim arrBasketItemInfo() As String = Split(Session("BasketItemInfo") & "", ";")
                numBasketItemID = arrBasketItemInfo(0)
                numEditVersionID = arrBasketItemInfo(1)
            End If

            If CLng(litVersionID.Text) <> numEditVersionID Then numBasketItemID = 0

            numVersionID = CLng(litVersionID.Text)
            objMiniBasket.ShowCustomText(CLng(litVersionID.Text), numQuantity, "", numBasketItemID)

            Session("AddItemVersionID") = litVersionID.Text
        End If
    End Sub

    Private Sub LoadAddItemToBasket()

        'If Not IsPostBack Or litVersionID.Text = Session("AddItemVersionID") Then

        'If nothing specified, set selector type based
        'on config setting.
        If c_strSelectorType = "" Then
            Dim strAddToBasketQtyCFG As String = FixNullFromDB(ObjectConfigBLL.GetValue("K:product.addtobasketqty", VersionsBLL.GetProductID_s(c_numVersionID)))
            If strAddToBasketQtyCFG Is Nothing Then strAddToBasketQtyCFG = ""
            If LCase(strAddToBasketQtyCFG) <> "" Then
                c_strSelectorType = LCase(FixNullFromDB(ObjectConfigBLL.GetValue("K:product.addtobasketqty", VersionsBLL.GetProductID_s(c_numVersionID))))
                If c_strSelectorType Is Nothing Then c_strSelectorType = ""
            Else
                c_strSelectorType = KartSettingsManager.GetKartConfig("frontend.basket.addtobasketdisplay")
            End If
        End If

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

        '' If UnitSize is <> 1, we need to force the textbox as quantity control
        If CSng(UnitSize) <> 1 Then c_strSelectorType = "textbox"

        Dim strMinimumAllowedQty As String = "1"

        '' Need to know if the decimal quantity is allowed or not
        If Math.Abs(CSng(UnitSize) Mod 1) > 0.0F Then
            '' UnitSize is decimal
            If CSng(UnitSize) > 1 Then strMinimumAllowedQty = UnitSize
            '' we need to exclude the "." if the unit size is decimal, so to accept both (numbers & ".")
            filQuantity.FilterType = AjaxControlToolkit.FilterTypes.Numbers Or AjaxControlToolkit.FilterTypes.Custom
            filQuantity.ValidChars = "."
        Else
            '' UnitSize is integer
            If CInt(UnitSize) > 1 Then strMinimumAllowedQty = CInt(UnitSize)
        End If

        'Set quantity selector type
        Select Case c_strSelectorType
            Case "textbox"
                'Textbox for quantity next to 'add' button

                If c_numVersionID = c_ItemEditVersionID AndAlso c_ItemEditVersionID > 0 Then
                    If Not IsPostBack Then txtItemsQuantity.Text = c_ItemEditQty
                Else
                    If Not IsPostBack OrElse Not IsNumeric(txtItemsQuantity.Text) Then txtItemsQuantity.Text = strMinimumAllowedQty
                End If

                txtItemsQuantity.Visible = True
                ddlItemsQuantity.Visible = False

            Case "none"
                'No field to input quantity next to 'add' button
                '(just adds a single item when button pushed, best
                'for sites where there are only single items for sale, or large
                'value items people are unlikely to order in quantity)

                txtItemsQuantity.Visible = False
                ddlItemsQuantity.Visible = False
                txtItemsQuantity.Text = 1

            Case Else
                'Defaults the selector to dropdown if not specified explicitly.
                Dim numCounter As Integer
                Dim bitValue As Byte = 1
                Try
                    bitValue = CByte(ddlItemsQuantity.Text)
                Catch ex As Exception
                End Try
                ddlItemsQuantity.Items.Clear()
                'Create dropdown values based on config setting
                For numCounter = 1 To CInt(KartSettingsManager.GetKartConfig("frontend.basket.addtobasketdropdown.max"))
                    ddlItemsQuantity.Items.Add(numCounter.ToString)
                Next

                If c_numVersionID = c_ItemEditVersionID And c_ItemEditVersionID > 0 Then
                    btnAdd.Text = GetGlobalResourceObject("_Kartris", "FormButton_Update")
                    If Not IsPostBack Then
                        If numCounter < c_ItemEditQty Then
                            ddlItemsQuantity.Items.Add(c_ItemEditQty)
                            ddlItemsQuantity.SelectedValue = c_ItemEditQty
                        Else
                            ddlItemsQuantity.SelectedValue = c_ItemEditQty
                        End If
                    Else
                        ddlItemsQuantity.Text = bitValue
                    End If
                Else
                    btnAdd.Text = GetGlobalResourceObject("_Kartris", "FormButton_Add")
                    If bitValue >= numCounter Then
                        ddlItemsQuantity.Items.Add(bitValue)
                        ddlItemsQuantity.SelectedValue = bitValue
                    End If
                    ddlItemsQuantity.Text = bitValue
                End If
                'If Not Page.IsPostBack Then
                txtItemsQuantity.Visible = False
                ddlItemsQuantity.Visible = True
                'End If
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
