'========================================================================
'Kartris - www.kartris.com
'Copyright 2020 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisBLL
Imports CkartrisEnumerations
Imports CkartrisDisplayFunctions
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class UserControls_Back_OptionsPopup
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Causes a read for the selected options
    ''' </summary>
    Public Event OptionsSelected(ByVal strOptions As String, ByVal numVersionID As Integer)

    Public Sub ShowPopup(ByVal numVersionID As Long, ByVal numProductID As Integer, ByVal strVersionCode As String)
        'lblVID_Options.Text = CStr(numVersionID)
        litVersionID.Text = CStr(numVersionID)
        litProductID.Text = CStr(numProductID)
        litProductName.Text = ProductsBLL._GetNameByProductID(numProductID, Session("LANG"))
        litVersionCode.Text = "&nbsp;&nbsp;-&nbsp;&nbsp;" & strVersionCode
        Dim blnUseCombinationPrice As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", CLng(numProductID)) = "1", True, False)
        '' Initializes/Loads the OptionsContainer UC to view the Options that are available for the Product.
        UC_OptionsContainer.InitializeOption(numProductID, Session("LANG"), blnUseCombinationPrice)

        popOptions.Show()
        updOptionsContainer.Update()
    End Sub

    Protected Sub btnSaveOptions_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSaveOptions.Click
        
        '' Reading the values of Options from the OptionsContainer in a muli-dimentional array
        ''  i.e. arrOptions(OPTION_GROUP_ID, COMMA_SEPARETED_SELECTED_VALUES)
        Dim strOptionString As String = UC_OptionsContainer.GetSelectedOptions()

        If strOptionString Is Nothing Then strOptionString = ""

        'purge double commas
        Do While strOptionString.Contains(",,")
            strOptionString = Replace(strOptionString, ",,", ",")
        Loop

        If Not strOptionString Is Nothing Then
            If strOptionString.EndsWith(",") Then strOptionString = strOptionString.TrimEnd((","))
            If strOptionString.StartsWith(",") Then strOptionString = strOptionString.TrimStart((","))
        End If

        '' ------------------------------------------
        '' Below is the code that will remove the duplicate options.
        Dim arrOptions() As String = strOptionString.Split(",")
        For i As Integer = 0 To arrOptions.Length - 1
            For j As Integer = 0 To i
                If i <> j Then
                    If arrOptions(j) = arrOptions(i) Then arrOptions(j) = ""
                End If
            Next
        Next
        Dim sbdOptions As New StringBuilder("")
        For i As Integer = 0 To arrOptions.Length - 1
            If arrOptions(i) <> "" Then
                sbdOptions.Append(arrOptions(i))
                If i <> arrOptions.Length - 1 Then sbdOptions.Append(",")
            End If
        Next
        strOptionString = sbdOptions.ToString()
        RaiseEvent OptionsSelected(strOptionString, litVersionID.Text)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not String.IsNullOrEmpty(litVersionID.Text) AndAlso IsNumeric(litVersionID.Text) AndAlso _
            Not String.IsNullOrEmpty(litProductID.Text) AndAlso IsNumeric(litProductID.Text) Then
            Dim blnUseCombinationPrice As Boolean = IIf(ObjectConfigBLL.GetValue("K:product.usecombinationprice", CLng(litProductID.Text)) = "1", True, False)
            '' Need to create options for the specific product, without selecting the radio control if exist
            UC_OptionsContainer.InitializeOption(CInt(litProductID.Text), Session("LANG"), blnUseCombinationPrice, False)
        End If
    End Sub

    ''' <summary>
    ''' resets the product id / version id of the options
    ''' </summary>
    Public Sub ClearIDs()
        litVersionID.Text = Nothing
        litProductID.Text = Nothing
        updPnlOptions.Update()
    End Sub
End Class
