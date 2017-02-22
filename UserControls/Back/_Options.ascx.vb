'========================================================================
'Kartris - www.kartris.com
'Copyright 2017 CACTUSOFT

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
Partial Class _Options
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

    Private WithEvents _Control As Object

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
                NewItem("-", 0, 0)
            Case "r"
                _OptionType = "Radio"
                _Control = New RadioButtonList
                If Not pIsMandatory Then NewItem(GetGlobalResourceObject("Kartris", "ContentText_None"), 0, 0, True)
                CType(_Control, RadioButtonList).CssClass = "radiobuttonlist"
            Case "c"
                _OptionType = "Check"
                _Control = New CheckBoxList
                CType(_Control, CheckBoxList).CssClass = "checkboxlist"
            Case Else
                Exit Sub
        End Select

        _Control.ID = "NewOption"
        
        Dim asyncTrigger As New AsyncPostBackTrigger
        asyncTrigger.ControlID = _Control.ID
        asyncTrigger.EventName = "SelectedIndexChanged"

        updOptions.Triggers.Add(asyncTrigger)

        phdOption.Controls.Add(_Control)
        
        '' Initializing the other class's attributes
        _GroupID = pGroupID
        _OptionName = pOptionName
        _OptionDescription = pOptionDescription

        _Mandatory = pIsMandatory

        If _Mandatory AndAlso _OptionType <> "Check" Then
            valRequiredField.ControlToValidate = _Control.ID
            valRequiredField.InitialValue = "0"
            valRequiredField.Enabled = True
        Else
            valRequiredField.Enabled = False
        End If
        '' Setting the UI controls' Text
        lblOptionGroupName.Text = pOptionName
        lblOptionDescription.Text = pOptionDescription
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

            strPriceFormatted = CurrenciesBLL.FormatCurrencyPrice( _
                Session("CUR_ID"), itemListOptionsPrice.Value, , _OptionType <> "DropDown")


            '' Changing the display text to the user with the amount increased if this option is selected.
            If _ChangePricesOnSelection Then itemListOptions.Text += Space(3) & "(+ " & strPriceFormatted & ")"
            'itemListOptions.Text += Space(3) & "(+ " & strPriceFormatted & ")"
        End If
        If pIsSelected Then
            _Control.ClearSelection()
            itemListOptions.Selected = pIsSelected
        End If

        _Control.Items.Add(itemListOptions)

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
            Try
                _SelectedText = _Control.SelectedItem.Text
                '' If the Option's type is checkBoxList, Then multiple values could be selected.
                If _OptionType = "Check" Then
                    For i As Integer = 0 To _Control.Items.Count - 1
                        If _Control.Items(i).Selected Then
                            _SelectedValues += CStr(_Control.Items(i).Value) + ","
                        End If
                    Next
                Else
                    _SelectedValues = CStr(_Control.SelectedValue)
                End If
            Catch ex As Exception
                '' This case used if there is only one Option; i.e. One CheckBoxList Item, so the selected value will be -1
                _SelectedText = ""
                _SelectedValues = ""

            End Try
            Return _SelectedValues
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' Reading the queryString 'strOptions' from the URL, to get the same selection
        ''  from the basket.
        If Not Request.QueryString("strOptions") Is Nothing Then
            Try
                SelectOption(Request.QueryString("strOptions"))
            Catch ex As Exception
            End Try
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
    End Sub
End Class
