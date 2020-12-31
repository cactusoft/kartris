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

Imports System.Web
Imports System.Web.UI

''' <summary>
''' This Class "OptionsContainer.ascx" introduces the User Control that is 
'''     responsible to view the Options for a Product.
''' IMPORTANT: You Need to call the "InitializeOption" Method BEFORE using
'''     this class(before running the page that holds the "OptionsContainer.ascx" User Control)
''' </summary>
''' <remarks></remarks>
Partial Class OptionsContainer
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' The Attributes of the "OptionsContainer" Class
    '''    _ProductID  -> Holds the ProductID of the Options being shown in the Container.
    '''    _LanguageID -> Holds the LanguageID of the Options being shown in the Container.
    '''    _CurrencyID -> Holds the CurrencyID of the Options' Prices being shown in the Container.
    ''' </summary>
    ''' <remarks>By Mohammad</remarks>
    Private _ProductID As Integer = -1
    Private _LanguageID As Short = -1
    Private _NoOptionsRows As Integer = -1

    'Sometimes we see errors in the page_load, it seems that _ProductID = -1 for some reason
    'If we raise an event, we can try to reset the options in the ProductVersions control,
    'if the event is triggered
    Public Event SomethingWentWrong()

    '' If this is true, will use the entered price for each option combination instead of adding the "selected option" price separately
    Private _UseCombinationPrices As Boolean = False
    Public ReadOnly Property IsUsingCombinationPrices As Boolean
        Get
            Return _UseCombinationPrices
        End Get
    End Property

    ''' <summary>
    ''' Loads the "OptionsContainer.ascx" and checks for validity.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The next -IF Statement- checks if the Product, Language, and the Currency all are have value,
        ''      otherwise it shows an error message specified in -lblErrorDefaults-
        'If Page.IsPostBack Then
        If Not (_ProductID = -1) Then
            'CreateProductOptions()
        Else
            'lblErrorDefaults.Visible = True
            If Me.Visible Then
                RaiseEvent SomethingWentWrong()
            End If
        End If
        'End If
    End Sub

    ''' <summary>
    ''' Returns the ProductID of the OptionContainer
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property ProductID() As Integer
        Get
            Return _ProductID
        End Get
    End Property

    ''' <summary>
    ''' Returns the LanguageID of the OptionContainer
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Public ReadOnly Property LanguageID() As Short
        Get
            Return _LanguageID
        End Get
    End Property

    ''' <summary>
    ''' Returns the Number of Rows in the OptionGroup Table
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public ReadOnly Property GetNoOfRows() As Integer
        Get
            Return _NoOptionsRows
        End Get
    End Property

    ''' <summary>
    ''' Creates a new instance of Options with specific Product, Language, and Currency.
    ''' </summary>
    ''' <param name="pProductID">The Options' ProductID to be viewed.</param>
    ''' <param name="pLanguageID">The Options' LanguageID to be viewed.</param>
    ''' <param name="pUseCombinationPrices">If this is true, will use the entered price for each option combination instead of adding the "selected option" price separately.</param>
    ''' <remarks>By Mohammad</remarks>
    ''' 'Public Sub InitializeOption(ByVal productID As Integer, ByVal languageID As Short, ByVal currencyID As Short)
    Public Sub InitializeOption(ByVal pProductID As Integer, ByVal pLanguageID As Short, ByVal pUseCombinationPrices As Boolean)
        _ProductID = pProductID
        _LanguageID = pLanguageID

        _NoOptionsRows = -1

        _UseCombinationPrices = pUseCombinationPrices

        CreateProductOptions()
    End Sub

    ''' <summary>
    ''' Creates the available options for the Product, and attches them to the Page.
    ''' </summary>
    ''' <remarks>By Mohammad</remarks>
    Private Sub CreateProductOptions()

        phdOptions.Controls.Clear()
        Trace.Warn("-------------Container.phdOptions.Controls.Clear()--------------------")

        lblErrorDefaults.Visible = False

        '' Creating a table to hold the Options of the specified Product.
        '' Also calling "VersionsBLL.GetProductOptions" to get the data from database.
        Dim tblOptions As New DataTable

        tblOptions = VersionsBLL.GetProductOptions(_ProductID, _LanguageID)
        _NoOptionsRows = tblOptions.Rows.Count

        If _NoOptionsRows = 0 Then
            Exit Sub
        End If
        Trace.Warn("-------------ProductID is:" & _ProductID & "--------------------")

        '' These variables to hold the attributes of the "Options" Class.
        Dim intOptionsGroupID As Int32, strOptionsName As String, strOptionsDesc As String, _
            chrOptionsType As Char, blnOptionsMandatory As Boolean = False

        '' The next -For Each- loop is read the available Options for the specified Product.
        Dim rowOptions As DataRow
        For Each rowOptions In tblOptions.Rows

            '' Reading the data from the -tblOptions- in to some variables.
            intOptionsGroupID = IIf(IsNotNULL(rowOptions("OPTG_ID")), rowOptions("OPTG_ID"), -1)
            strOptionsName = IIf(IsNotNULL(rowOptions("OPTG_Name")), rowOptions("OPTG_Name"), Nothing)
            strOptionsDesc = IIf(IsNotNULL(rowOptions("OPTG_Desc")), rowOptions("OPTG_Desc"), "")
            chrOptionsType = IIf(IsNotNULL(rowOptions("OPTG_OptionDisplayType")), rowOptions("OPTG_OptionDisplayType"), Nothing)
            blnOptionsMandatory = CBool(rowOptions("P_OPTG_MustSelected"))

            '' If some objects didn't have value then Move to the next Option
            If intOptionsGroupID = -1 Or strOptionsName = Nothing Or chrOptionsType = Nothing Then
                Continue For
            End If

            '' Creating new dataTable to hold the values for specified Option.
            Dim tblOptionValues As New DataTable
            tblOptionValues = VersionsBLL.GetProductOptionValues(_ProductID, _LanguageID, intOptionsGroupID)

            If chrOptionsType = "l" Then
                If tblOptionValues.Rows.Count = 1 Then
                    chrOptionsType = "c"
                Else
                    chrOptionsType = "r"
                End If
            End If

            '' Creating new User Control -UC_Options- to hold the values for the specified Option.
            Dim UC_Option As Options

            '' Loading the User Cotrol "Options.ascx" in the newly created -UC_Options-
            ''      to be shown in the page.
            UC_Option = CType(LoadControl("Options.ascx"), Options)

            '' Initializing the -UC_Options-
            UC_Option.CreateOption(intOptionsGroupID, strOptionsName, chrOptionsType, strOptionsDesc, blnOptionsMandatory)

            '' The next -For Each- loop is read the values of the specified option
            ''      and to add these values to the User Control -UC_Options-.
            Dim rowOptionValues As DataRow, blnIsSelectedOption As Boolean = False, numSelectedOptions As Integer = 0
            For Each rowOptionValues In tblOptionValues.Rows
                blnIsSelectedOption = CBool(rowOptionValues("P_OPT_Selected"))
                If blnIsSelectedOption Then numSelectedOptions += 1
                '' Creating new item(value) for each option.
                With UC_Option
                    .NewItem(CStr(rowOptionValues("OPT_Name")), CStr(CInt(rowOptionValues("OPT_ID"))), _
                             CDbl(rowOptionValues("P_OPT_PriceChange")), CBool(rowOptionValues("P_OPT_Selected")), _
                             Not _UseCombinationPrices)
                End With
            Next
            If chrOptionsType = "r" AndAlso numSelectedOptions = 0 Then UC_Option.SelectFirstOption()

            '' Adding an Event Handler for the User Control -UC_Options-
            AddHandler UC_Option.Option_IndexChanged, AddressOf UCEvent_Options_IndexChaged

            '' Adding the newly created User Control -UC_Options- to the -pnlOptions-
            phdOptions.Controls.Add(UC_Option)
            Trace.Warn("--------------phdOptions.Controls.Add(UC_Option)------------------------")

        Next
    End Sub

    ''' <summary>
    ''' Returns True if the specified dataField has a value.
    ''' </summary>
    ''' <param name="pDataField"> The DataBase Field to check. </param>
    ''' <returns></returns>
    ''' <remarks>By Mohammad</remarks>
    Private Function IsNotNULL(ByVal pDataField As Object) As Boolean
        Try
            If pDataField Is DBNull.Value Then Return False
        Catch ex As Exception
            Return False
        End Try
        Return True
    End Function

    ''' <summary>
    ''' Used to check the selection validation in the options.
    ''' </summary>
    ''' <returns>List of "option's names" for the non-selected options separated by comma (,). </returns>
    ''' <remarks></remarks>
    Public Function CheckForValidSelection() As String
        '' strNotValidStrings will hold the invalid options (as comma separated names).
        Dim strNotValidStrings As String = Nothing
        Trace.Warn("---------------------OptionContainer.CheckForValidSelection -- NO. OF Controls is:" & phdOptions.Controls.Count)
        For Each ctrl As Control In phdOptions.Controls
            Try
                If ctrl.GetType.ToString.ToLower.Contains("options") Then
                    '' Check for validation
                    If Not CType(ctrl, Options).IsValidSelection() Then
                        '' Not selected option.
                        strNotValidStrings += CType(ctrl, Options).GetOptionName() & ","
                        '' Highlight the Name of the Option, by sending a parameter as NotValid
                        CType(ctrl, Options).HighlightValidation(False)
                    Else
                        '' Valid Selection
                        '' Rest the color of the Option Name, by sending a parameter as Valid
                        CType(ctrl, Options).HighlightValidation(True)
                    End If
                End If
            Catch ex As Exception
                '' Means Non Option Control
            End Try
        Next
        Return strNotValidStrings
    End Function

    ''' <summary>
    ''' Use this Event to Write the Code that will be run if the Options' Index has been changed.
    ''' </summary>
    ''' <param name="sender">The name of the Options' control.</param>
    ''' <remarks>By Mohammad</remarks>
    Protected Sub UCEvent_Options_IndexChaged(ByVal sender As Options) Handles UC_HiddenOption.Option_IndexChanged
        '' Write out the code to be run after the index has been changed.
        '' <HINT>
        ''  -- If You want to catch an Options' Control in the Page and to call a method 
        ''          for that Option' ControlUse the following Code:
        ''  ------------------------------------------------------------------------------
        ''      Dim obj As Object
        ''      For Each obj In pnlOptions.Controls
        ''          If obj.GetType.ToString() = "ASP.ProductOptions_ascx" Then
        ''             CType(obj, Options).<The MethodName>
        ''          End If
        ''      Next
        ''  ------------------------------------------------------------------------------
        '' </HINT>
        Trace.Warn("UC_OptionsEvent IN Container")
        Dim objOption As Object
        Dim numTotalPrice As Single = 0.0F
        For Each objOption In phdOptions.Controls
            If objOption.GetType.ToString() = sender.GetType.ToString() Then
                numTotalPrice += CType(objOption, Options).GetPriceChange()
            End If
        Next
        RaiseEvent Event_OptionPriceChanged(numTotalPrice)
    End Sub

    Public Function GetSelectedPrice() As Single
        Dim UC_Option As Options
        UC_Option = CType(LoadControl("Options.ascx"), Options)

        Dim numTotalPrice As Single = 0.0F
        For Each objOption In phdOptions.Controls
            If objOption.GetType.ToString() = UC_Option.GetType.ToString() Then
                numTotalPrice += CType(objOption, Options).GetPriceChange()
            End If
        Next
        Return numTotalPrice
    End Function

    Public Function GetSelectedOptions() As String

        Dim strSelectedOptionValues As String = Nothing
        Dim numCounter As Integer = 0

        For Each ctlOption As Control In phdOptions.Controls
            Try
                If ctlOption.GetType.ToString().ToLower.Contains("options") Then
                    If [String].IsNullOrEmpty(CType(ctlOption, Options).GetSelectedValues()) Then Continue For
                    strSelectedOptionValues += CType(ctlOption, Options).GetSelectedValues() & ","
                    numCounter += 1
                End If
            Catch ex As Exception
                '' Means Non Option Control
                Trace.Warn("-------------- EXCEPTION IN OptionsContainer.GetSelectedOptions -------------------")
            End Try
        Next
        If Not [String].IsNullOrEmpty(strSelectedOptionValues) Then
            'purge double commas
            Do While strSelectedOptionValues.Contains(",,")
                strSelectedOptionValues = Replace(strSelectedOptionValues, ",,", ",")
            Loop
            'remove the starting and ending commas
            If strSelectedOptionValues.StartsWith(",") Then strSelectedOptionValues = strSelectedOptionValues.TrimStart(",")
            If strSelectedOptionValues.EndsWith(",") Then strSelectedOptionValues = strSelectedOptionValues.TrimEnd(",")
        End If

        Return strSelectedOptionValues
    End Function

    Public Event Event_OptionPriceChanged(ByVal sender As Single)

End Class
