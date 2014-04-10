'========================================================================
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

''' <summary>
''' Options.ascx - User Control that views the available Options for a specific Product.
''' This Class must be used with the "OptionsContainer.ascx"
''' All the need is to write your own code to handle the (Option_IndexChanged) Event
'''     in the "OptionsContainer.ascx.vb" file.
''' </summary>
''' <remarks>By Mohammad</remarks>
Partial Class Options
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' The Attributes of the "Options" Class
    '''    _ProductID  -> 
    '''    _LanguageID -> Holds the LanguageID of the Options being shown in the Container.
    '''    _CurrencyID -> Holds the CurrencyID of the Options' Prices being shown in the Container.
    ''' </summary>
    ''' <remarks>By Mohammad</remarks>
    Private _GroupID As Integer = -1            ' The GroupID (OPTG_ID).
    Private _OptionName As String = ""          ' The Name (OPTG_Name)  e.g. Size, Color ...
    Private _OptionType As String = ""          ' The Display Type Name (OPTG_OptionDisplayType) 
    '                                           '       e.g. 'r'->Radio, 'c'->CheckBox, 'd'->DropDown.
    Private _OptionDescription As String = ""   ' The Desc (OPTG_Desc)
    Private _Mandatory As Boolean = False       ' If the user must select at least 1 option
    Private _ChangePricesOnSelection As Boolean = False ' This indicates combination prices
    Private _SelectedText As String = ""        ' The text that is currently selected by user.
    Private _SelectedValues As String = ""      ' The values (IDs) that are currently selected by user.
    Private _SelectedPrice As Single = 0        ' The price change value that is currently selected by user.

    Private WithEvents _Control As Object
    Private WithEvents _ControlPrice As Object
    
    Private WithEvents ddl As DropDownList
    Private WithEvents rbtn As RadioButtonList
    Private WithEvents chk As CheckBoxList

    ''' <summary>
    ''' Used To Initialize the class' attributes.
    ''' IMPORTANT: Must be called before trying to fill in options' values.
    ''' </summary>
    ''' <param name="pGroupID">The ID Number of the Option Group</param>
    ''' <param name="pOptionName">The Name that will appears in the label left to the Option</param>
    ''' <param name="pOptionType">The Display Type of the Option ('r'->RadioList, 'd'->DropDownList, or 'c'->CheckBoxList) </param>
    ''' <param name="pOptionDescription">The Description of the Option</param>
    ''' <param name="pIsMandatory">True(User must select at least one value), False(Otherwise) </param>
    ''' <remarks>By Mohammad</remarks>
    ''' Public Sub CreateOption(ByVal groupID As Integer, ByVal optionName As String, ByVal optionType As Char, _
    '''                         Optional ByVal optionDescription As String = "", Optional ByVal currencyID As Short = 1, _
    '''                         Optional ByVal mandatory As Boolean = False)
    Public Sub CreateOption(ByVal pGroupID As Integer, ByVal pOptionName As String, ByVal pOptionType As Char, _
                        Optional ByVal pOptionDescription As String = "", Optional ByVal pIsMandatory As Boolean = False)

        ' Specifing the Display Type, and viewing the proper panel for the display.
        Select Case pOptionType
            Case "d"
                _OptionType = "DropDown"
                _Control = New DropDownList
                _ControlPrice = New DropDownList
                NewItem("-", 0, 0)
                AddHandler CType(_Control, DropDownList).SelectedIndexChanged, AddressOf indxChanged
            Case "r"
                _OptionType = "Radio"
                _Control = New RadioButtonList
                _ControlPrice = New RadioButtonList
                AddHandler CType(_Control, RadioButtonList).SelectedIndexChanged, AddressOf indxChanged
                If Not pIsMandatory Then NewItem(GetGlobalResourceObject("Kartris", "ContentText_None"), 0, 0, True)
                CType(_Control, RadioButtonList).CssClass = "radiobuttonlist"
            Case "c"
                _OptionType = "Check"
                _Control = New CheckBoxList
                _ControlPrice = New CheckBoxList
                AddHandler CType(_Control, CheckBoxList).SelectedIndexChanged, AddressOf indxChanged
                CType(_Control, CheckBoxList).CssClass = "checkboxlist"
            Case Else
                Exit Sub
        End Select

        _Control.ID = "NewOption"
        _Control.AutoPostBack = True
        _ControlPrice.Visible = False

        Dim asyncTrigger As New AsyncPostBackTrigger
        asyncTrigger.ControlID = _Control.ID
        asyncTrigger.EventName = "SelectedIndexChanged"

        updOptions.Triggers.Add(asyncTrigger)
        
        phdOption.Controls.Add(_Control)
        phdOption.Controls.Add(_ControlPrice)
        
        '' Initializing the other class's attributes
        _GroupID = pGroupID
        _OptionName = pOptionName
        _OptionDescription = pOptionDescription

        _Mandatory = pIsMandatory

        '' Setting the UI controls' Text
        lblOptionGroupName.Text = pOptionName
        litOptionDescription.Text = pOptionDescription

        If KartSettingsManager.GetKartConfig("frontend.optiongroups.showdescription") = "y" AndAlso Not String.IsNullOrEmpty(pOptionDescription) Then
            phdOptionGroupDescription.Visible = True
        End If
        lblCurrencyID.Text = Session("CUR_ID")

    End Sub

    ''' <summary>
    ''' Creates a new Item (Value) for the Option.
    ''' </summary>
    ''' <param name="pItemText">The String that appears to the user (Display Field)</param>
    ''' <param name="pItemValue">The String that holds the ID of the OptionValue (Value Field) </param>
    ''' <param name="pItemPriceChange">The amount(Numeric) of the price change for the OptionValue</param>
    ''' <param name="pIsSelected">True(The Item is to be selected in UI), False(Otherwise)</param>
    ''' <remarks>By Mohammad</remarks>
    Public Sub NewItem(ByVal pItemText As String, ByVal pItemValue As String, _
                       Optional ByVal pItemPriceChange As Single = 0, Optional ByVal pIsSelected As Boolean = False, _
                       Optional ByVal pChangePriceOnSelection As Boolean = True)

        Dim itemListOptions As New ListItem(pItemText, pItemValue)
        Dim itemListOptionsPrice As New ListItem(pItemText & "-" & CStr(pItemPriceChange), pItemPriceChange)
        Dim strPriceFormatted As String = ""

        _ChangePricesOnSelection = pChangePriceOnSelection

        '' The next -IF Statement- will change the price amount regarding the current Currency.
        If pItemPriceChange <> 0 Then

            '' Convert the Price Amount to the current Currency,
            ''      and then Rounding to 2 digits after the decimal point.
            itemListOptionsPrice.Value = CurrenciesBLL.ConvertCurrency(Session("CUR_ID"), pItemPriceChange)

            'If _OptionType = "d" Then
            strPriceFormatted = CurrenciesBLL.FormatCurrencyPrice( _
                Session("CUR_ID"), itemListOptionsPrice.Value, , _OptionType <> "DropDown")
            'End If


            '' Changing the display text to the user with the amount increased if this option is selected.
            If _ChangePricesOnSelection Then itemListOptions.Text += Space(3) & "(+ " & strPriceFormatted & ")"
            'itemListOptions.Text += Space(3) & "(+ " & strPriceFormatted & ")"
        End If
        If pIsSelected Then
            _Control.ClearSelection()
            itemListOptions.Selected = pIsSelected
        End If

        'itemListOptions.Selected = pIsSelected

        _Control.Items.Add(itemListOptions)

        'If only one option, then we will see a checkbox. In v1.3
        'and earlier, this would effectively make the 'optional'
        'setting for this option irrelevant, as a checkbox input
        'can be left unchecked to indicate a selection of 'no'. 
        'From 1.4 onwards, we interpret a single option which is
        'not optional (i.e. required) as the option being selected.
        'This way, you can set up a product as an options product
        'even if this is only one option to begin with (e.g. size)
        'but make this single size selection required. Or you can
        'use it to emphasize something that is included with a
        'product and cannot be removed.
        If _Mandatory And _OptionType = "Check" Then
            _Control.Items(0).Selected = True
            _Control.Items(0).Enabled = False
        End If

        _ControlPrice.Items.Add(itemListOptionsPrice)

        If pIsSelected Then indxChanged(Me, New EventArgs)

    End Sub

    ''' <summary>
    ''' Returns the Group ID of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetOptionGroupID() As Integer
        Get
            Return _GroupID
        End Get
    End Property

    ''' <summary>
    ''' Returns the Name of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetOptionName() As String
        Get
            Return _OptionName
        End Get
    End Property

    ''' <summary>
    ''' Returns the Display Type Name of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetOptionType() As String
        Get
            Return _OptionType
        End Get
    End Property

    ''' <summary>
    ''' Returns the Description Text of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetDescription() As String
        Get
            Return _OptionDescription
        End Get
    End Property

    ''' <summary>
    ''' Returns the Selected Text of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetSelectedText() As String
        Get
            Return _SelectedText
        End Get
    End Property

    ''' <summary>
    ''' Returns the Selected Value(ID) of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetSelectedValues() As String
        Get
            Return _SelectedValues
        End Get
    End Property

    ''' <summary>
    ''' Returns the Price Change Amount of the Option
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property GetPriceChange() As Single
        Get
            Return _SelectedPrice
        End Get
    End Property

    ''' <summary>
    ''' True(If this option must has at least 1 value selected), False(Otherwise)
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property IsMandatory() As Boolean
        Get
            Return _Mandatory
        End Get
    End Property

    Public ReadOnly Property ChangePricesOnSelection() As Boolean
        Get
            Return _ChangePricesOnSelection
        End Get
    End Property

    ''' <summary>
    ''' Check if the Option is valid or not Depending in the Mandatory Attribute
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public Function IsValidSelection() As Boolean
        '' If the current Option is mandatory, then it needs to be checked.
        If IsMandatory Then
            Select Case _OptionType
                Case "DropDown"
                    '' If the Option is viewed as DropDownList,
                    ''  Then need to have a non-zero-value for the selection to be valid.
                    If _Control.SelectedValue = 0 Then
                        Return False
                    End If

                Case "Radio"
                    '' If the Option is viewed as RadioList,
                    ''  Then need to have a selection to be valid 
                    ''  (the selected index must be greated than or equals to zero "not -1")
                    If _Control.SelectedIndex < 0 Then
                        Return False
                    End If

                Case Else
                    '' Otherwise like CheckBoxList, must be valid.

                    Return True
            End Select
        End If

        Return True
    End Function

    ''' <summary>
    ''' Used to check for the price changing after the options' selection ..
    ''' </summary>
    ''' <param name="pSender"></param>
    ''' <param name="pEvent"></param>
    ''' <remarks></remarks>
    Private Sub indxChanged(ByVal pSender As Object, ByVal pEvent As EventArgs) Handles ddl.SelectedIndexChanged, rbtn.SelectedIndexChanged, chk.SelectedIndexChanged
        Try
            '' Select the same identical Price Control as well.
            _ControlPrice.SelectedIndex = _Control.SelectedIndex
            _SelectedText = _Control.SelectedItem.Text
            '' If the Option's type is checkBoxList, Then multiple values could be selected.
            If _OptionType = "Check" Then
                For i As Integer = 0 To _Control.Items.Count - 1
                    If _Control.Items(i).Selected Then
                        _SelectedValues += CStr(_Control.Items(i).Value) + ","
                        _SelectedPrice += CDbl(_ControlPrice.Items(i).Value)
                    End If
                Next
            Else
                _SelectedValues = CStr(_Control.SelectedValue)
                _SelectedPrice = CDbl(_ControlPrice.SelectedValue)
            End If

            If IsValidSelection() Then lblOptionGroupName.CssClass = ""

        Catch ex As Exception
            '' This case used if there is only one Option; i.e. One CheckBoxList Item, so the selected value will be -1
            _SelectedText = ""
            _SelectedValues = ""
            _SelectedPrice = 0.0F

        End Try

        RaiseEvent Option_IndexChanged(Me)

    End Sub

    ''' <summary>
    ''' Fired after the index of the option was changed 
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <remarks>By Mohammad</remarks>
    Public Event Option_IndexChanged(ByVal sender As Object)

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' Reading the queryString 'strOptions' from the URL, to get the same selection
        ''  from the basket.
        If Not Request.QueryString("strOptions") Is Nothing Then
            Try
                SelectOption(Request.QueryString("strOptions"))
                indxChanged(Me, New EventArgs)  '' To get the price changes (depending on the selection).
            Catch ex As Exception
            End Try
        End If
        If Page.IsPostBack Then
            Try
                indxChanged(Me, New EventArgs)
            Catch ex As Exception
            End Try
        End If
    End Sub

    ''' <summary>
    ''' Highlight the name of the non-selected option (if its marked as mandatory)
    ''' </summary>
    ''' <param name="pIsValidSelection"></param>
    ''' <remarks></remarks>
    Public Sub HighlightValidation(Optional ByVal pIsValidSelection As Boolean = True)
        If Not pIsValidSelection Then
            lblOptionGroupName.CssClass = "highlight_error"
        Else
            lblOptionGroupName.CssClass = ""
        End If
    End Sub

    ''' <summary>
    ''' Makes an option selection depending on the strOptions Query String Variable
    ''' </summary>
    ''' <param name="pSelectedOptions">Comma separated list of the options' IDs to be selected.</param>
    ''' <remarks></remarks>
    Public Sub SelectOption(ByVal pSelectedOptions As String)

        Dim arrOptions() As String = New String() {""}
        arrOptions = pSelectedOptions.Split(",")

        For i As Integer = 0 To arrOptions.GetUpperBound(0)
            For j As Integer = 0 To _Control.Items.Count - 1
                If _Control.Items(j).Value = arrOptions(i) Then
                    If _OptionType = "Check" Then
                        ' CheckBoxList
                        _Control.Items(j).Selected = True
                    Else
                        ' DropDownList & RadioButtonList
                        _Control.SelectedIndex = j
                    End If

                End If
            Next
        Next

    End Sub

    Public Sub SelectFirstOption()
        _Control.SelectedIndex = 0
        indxChanged(Me, New EventArgs)
    End Sub
End Class
