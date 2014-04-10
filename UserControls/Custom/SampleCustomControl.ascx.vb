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
Imports KartSettingsManager

''' <summary>
''' Sample Custom Control - must always inherit KartrisClasses.CustomProductControl
''' Has 2 dropdowns - width and length, price is just calculated by multiplying selected width and length
''' </summary>
''' <remarks></remarks>
Public Class SampleCustomControl
    Inherits KartrisClasses.CustomProductControl
    Private _ParameterValues As String = ""
    Private _ItemDescription As String = ""
    Private _ItemPrice As Double = -1


#Region "REQUIRED METHODS" 'The methods inside this region must be always be implemented to ensure compatibility with Kartris Custom Product Control code
    ''' <summary>
    ''' Calculates the price that will result from processing the given parameter values
    ''' Primarily used to check if stored price in the db/basket is correct, used before checkout code processes an order
    ''' </summary>
    ''' <param name="ParameterValues">Comma separated list of parameters to be computed</param>
    ''' <returns></returns>
    ''' <remarks>returns -1 if parameters are invalid</remarks>
    Public Overrides Function CalculatePrice(ParameterValues As String) As Double
        Dim _CalculatedPrice As Double
        Try
            Dim arrParameters As String() = Split(ParameterValues, ",")
            'Width and Length for this custom control so we're expecting 2 indexes
            _CalculatedPrice = arrParameters(0) * arrParameters(1)
        Catch ex As Exception
            _CalculatedPrice = -1
        End Try
        
        Return _CalculatedPrice
    End Function

    ''' <summary>
    ''' Instructs the user control to compute and populate the properties with the correct values based on the selected options in the user control
    ''' This function must be called before retrieving the 3 properties - ParameterValues, ItemDescription and ItemPrice
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks>should return either "success" or an error message</remarks>
    Public Overrides Function ComputeFromSelectedOptions() As String
        Try
            'Generate an item description string based on the selected options in the control
            _ItemDescription = ddlWidth.SelectedValue & " x " & ddlLength.SelectedValue & " item"

            'Prepare the comma separated list of parameter values based on the selected options in the control
            _ParameterValues = ddlWidth.SelectedValue & "," & ddlLength.SelectedValue

            'Formula to compute the item price - this varies from one custom product control to another
            _ItemPrice = ddlLength.SelectedValue * ddlWidth.SelectedValue

            litCustomPrice.Visible = True
            lblCustomPrice.Visible = True
            litCustomPrice.Text = CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), _ItemPrice)

            Return "success"
        Catch ex As Exception
            litCustomPrice.Visible = False
            lblCustomPrice.Visible = False
            'An error occurred while trying to compute item price, return the error message to the user
            Return ex.Message
        End Try
        
    End Function

    ''' <summary>
    ''' Returns the item description based on the selected options in the control
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Overrides ReadOnly Property ItemDescription As String
        Get
            Return _ItemDescription
        End Get
    End Property

    ''' <summary>
    ''' Returns the computed price from the selected options in the control
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Overrides ReadOnly Property ItemPrice As Double
        Get
            Return _ItemPrice
        End Get
    End Property

    ''' <summary>
    ''' Returns the comma separated list of values from the selected options in the control
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Overrides ReadOnly Property ParameterValues As String
        Get
            Return _ParameterValues
        End Get
    End Property

#End Region

#Region "Custom Code" 'This region of code will vary from one custom product control to another. Developer has freedom to add methods here.
    ''' <summary>
    ''' Handle SelectedIndexChanged event for both width and length dropdowns
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub AnyDropdown_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlLength.SelectedIndexChanged, ddlWidth.SelectedIndexChanged
        ComputeFromSelectedOptions()
    End Sub
    ''' <summary>
    ''' Compute price based on initial values when control is loaded for the first time
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub Me_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            ComputeFromSelectedOptions()
        End If
    End Sub

#End Region

End Class
