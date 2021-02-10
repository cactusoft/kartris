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
Imports kartrisTaxDataTableAdapters
Imports CkartrisFormatErrors
Imports KartSettingsManager
Public Class TaxBLL

    Private Shared _Adptr As TaxRatesTblAdptr = Nothing
    Protected Shared ReadOnly Property Adptr() As TaxRatesTblAdptr
        Get
            _Adptr = New TaxRatesTblAdptr
            Return _Adptr
        End Get
    End Property

    Public Shared Function GetTaxRate(ByVal numTaxID As Byte) As Double
        Try
            Return CDbl((GetTaxRateFromCache.Select("T_ID=" & numTaxID))(0)("T_Taxrate"))
        Catch ex As Exception
        End Try
        Return 0
    End Function
    Public Shared Function GetClosestRate(ByVal numComputedRate As Double) As Double
        Try
            Return CDbl(Adptr.GetClosestRate(numComputedRate))
        Catch ex As Exception
        End Try
        Return Nothing
    End Function
    Public Shared Function GetQBTaxRefCode(ByVal strVersionCodeNumber As String) As String
        Try
            Return Adptr.GetQBTaxRefCodeOfVerCode(strVersionCodeNumber)
        Catch ex As Exception
        End Try
        Return ""
    End Function
    Public Shared Function GetQBTaxRefCode(ByVal intTaxID As Integer) As String
        Try
            Return CStr((GetTaxRateFromCache.Select("T_ID=" & intTaxID))(0)("T_QBRefCode"))
        Catch ex As Exception
        End Try
        Return ""
    End Function
    Public Shared Function GetQBTaxRefCode(ByVal dblTaxRate As Double) As String
        Try
            Return CStr((GetTaxRateFromCache.Select("T_TaxRate=" & dblTaxRate))(0)("T_QBRefCode"))
        Catch ex As Exception
        End Try
        Return ""
    End Function
    Protected Friend Shared Function _GetTaxRatesForCache() As DataTable
        Return Adptr._GetTaxRates()
    End Function

    Public Shared Function _UpdateTaxRate(ByVal intTaxID As Byte, ByVal snglTaxRate As Single, ByVal strQBRefCode As String, ByVal strMsg As String) As Boolean
        Dim strConnString As String = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ToString()
        Using sqlConn As New SqlConnection(strConnString)
            Dim cmdUpdateTax As SqlCommand = sqlConn.CreateCommand
            cmdUpdateTax.CommandText = "_spKartrisTaxRates_Update"
            Dim savePoint As SqlTransaction = Nothing
            cmdUpdateTax.CommandType = CommandType.StoredProcedure
            Try
                cmdUpdateTax.Parameters.AddWithValue("@T_ID", intTaxID)
                cmdUpdateTax.Parameters.AddWithValue("@T_Taxrate", snglTaxRate)
                cmdUpdateTax.Parameters.AddWithValue("@T_QBRefCode", strQBRefCode)

                sqlConn.Open()
                savePoint = sqlConn.BeginTransaction()
                cmdUpdateTax.Transaction = savePoint

                cmdUpdateTax.ExecuteNonQuery()
                savePoint.Commit()
                Return True
            Catch ex As Exception
                If Not savePoint Is Nothing Then savePoint.Rollback()
                ReportHandledError(ex, Reflection.MethodBase.GetCurrentMethod(), strMsg)
            Finally
                If sqlConn.State = ConnectionState.Open Then sqlConn.Close() : savePoint.Dispose()
            End Try
        End Using
        Return False
    End Function
End Class

Public Class TaxRegime
    Private Shared _Name As String
    Private Shared _DTax_Type As String
    Private Shared _DTax2_Type As String
    Private Shared _VTax_Type As String
    Private Shared _VTax2_Type As String
    Private Shared _Formulas As List(Of KartrisNameValuePair)
    Private Shared _DTaxNames As List(Of KartrisNameValuePair)
    Private Shared _DTax2Names As List(Of KartrisNameValuePair)
    Private Shared _CalculatePerItem As Boolean
    Private Shared _FormulaNameToFind As String
    ''' <summary>
    ''' Tax Regime Name
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property Name As String
        Get
            Return _Name
        End Get
    End Property
    Public Shared ReadOnly Property DTax_Type As String
        Get
            Return _DTax_Type
        End Get
    End Property
    Public Shared ReadOnly Property DTax_Type2 As String
        Get
            Return _DTax2_Type
        End Get
    End Property
    Public Shared ReadOnly Property VTax_Type As String
        Get
            Return _VTax_Type
        End Get
    End Property
    Public Shared ReadOnly Property VTax_Type2 As String
        Get
            Return _VTax2_Type
        End Get
    End Property
    ''' <summary>
    ''' Holds the list of Tax Rate Calculation Formulas for different D_TaxExtra values
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property Formulas As List(Of KartrisNameValuePair)
        Get
            Return _Formulas
        End Get
    End Property
    ''' <summary>
    ''' Holds the list of D_Tax Names for different languages
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property DTaxNames As List(Of KartrisNameValuePair)
        Get
            Return _DTaxNames
        End Get
    End Property
    ''' <summary>
    ''' Holds the list of D_Tax2 Names for different languages
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property DTax2Names As List(Of KartrisNameValuePair)
        Get
            Return _DTax2Names
        End Get
    End Property
    ''' <summary>
    ''' Determines if Regime calculate tax per item or against whole order value
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared ReadOnly Property CalculatePerItem As Boolean
        Get
            Return _CalculatePerItem
        End Get
    End Property
    Public Shared Sub LoadTaxConfigXML()
        Try
            Dim docXML As XmlDocument = New XmlDocument
            'Load the TaxScheme Config file file from web root
            docXML.Load(HttpContext.Current.Server.MapPath("~/TaxRegime.Config"))

            Dim lstNodes As XmlNodeList
            Dim ndeTaxRegime As XmlNode

            _Name = ConfigurationManager.AppSettings("TaxRegime").ToUpper
            Dim strRegimeNodePath As String = "/configuration/" & _Name & "TaxRegime"
            ndeTaxRegime = docXML.SelectSingleNode(strRegimeNodePath)

            'Get the regime's calculation mode - peritem(tax is calculated per item), perorder (tax is calculated against the whole order value)
            If ndeTaxRegime.Attributes.GetNamedItem("mode").Value = "PerItem" Then _CalculatePerItem = True Else _CalculatePerItem = False

            'get tax fields types *boolean or double(rate)* -> D_Tax, D_Tax2, V_Tax, V_Tax2
            ndeTaxRegime = docXML.SelectSingleNode(strRegimeNodePath & "/TaxFields/D_Tax")
            _DTax_Type = ndeTaxRegime.Attributes.GetNamedItem("type").Value

            ndeTaxRegime = docXML.SelectSingleNode(strRegimeNodePath & "/TaxFields/D_Tax2")
            If ndeTaxRegime IsNot Nothing Then
                _DTax2_Type = ndeTaxRegime.Attributes.GetNamedItem("type").Value
            Else
                _DTax2_Type = ""
            End If

            ndeTaxRegime = docXML.SelectSingleNode(strRegimeNodePath & "/TaxFields/V_Tax")
            If ndeTaxRegime IsNot Nothing Then _VTax_Type = ndeTaxRegime.Attributes.GetNamedItem("type").Value Else _VTax_Type = ""

            ndeTaxRegime = docXML.SelectSingleNode(strRegimeNodePath & "/TaxFields/V_Tax2")
            If ndeTaxRegime IsNot Nothing Then _VTax2_Type = ndeTaxRegime.Attributes.GetNamedItem("type").Value Else _VTax2_Type = ""

            'loop through TaxRateCalculation nodes and add them all to the Formulas property
            lstNodes = docXML.SelectNodes(strRegimeNodePath & "/TaxRateCalculation")
            _Formulas = New List(Of KartrisNameValuePair)
            For Each ndeTaxRegime In lstNodes
                Dim taxEquation As New KartrisNameValuePair
                'We only have a single formula (taxratecalculation node) if type attribute is empty so just name it as default
                If ndeTaxRegime.Attributes.GetNamedItem("type") IsNot Nothing Then taxEquation.Name = ndeTaxRegime.Attributes.GetNamedItem("type").Value Else taxEquation.Name = "default"
                taxEquation.Value = ndeTaxRegime.Attributes.GetNamedItem("value").Value

                _Formulas.Add(taxEquation)
            Next

        Catch ex As Exception
            'We want to write a log entry.
            CkartrisFormatErrors.LogError(ex.Message & vbCrLf & "This suggests the TaxRegime.config file on the root of the site is either corrupted, or permissions prevent it being read.")
        End Try


    End Sub

    ''' <summary>
    ''' Calculate the applicable tax rate
    ''' </summary>
    ''' <param name="V_Tax">Product Version Tax. The tax that is defined when creating or editting a single product version</param>
    ''' <param name="V_Tax2">Product Version Tax 2. Same use as V_Tax but used in countries with a 2 tier tax system (e.g. Canada)</param>
    ''' <param name="D_Tax">Destination Country Tax. The tax applicable in the destination country</param>
    ''' <param name="D_Tax2">Destination Country Tax 2. Same as D_Tax but used in countries with a 2 tier tax system (e.g. Canada)</param>
    ''' <param name="D_TaxExtra">The Tax Rate Calculation Type Name. View TaxRegime.Default and then for the country of interest look 
    ''' at the TaxRateCalculation node. If there is no node name then there is only one calculation, if there are multiple nodes then 
    ''' the name is used here to descriminate between them. From v3.0001, we also use to mark EU countries</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function CalculateTaxRate(ByVal V_Tax As Double, ByVal V_Tax2 As Double, ByVal D_Tax As Double,
                                         ByVal D_Tax2 As Double, ByVal D_TaxExtra As String) As Double

        Dim tblCalculate As New DataTable
        Dim formula As String = "({0})"
        Dim strCorrectFormula As String

        If Not String.IsNullOrEmpty(D_TaxExtra) Then
            If D_TaxExtra <> "EU" Then 'We now use this field to mark EU countries
                'D_TaxExtra has a value so must match it to the TaxRateCalculation Name to get the correct Formula
                _FormulaNameToFind = D_TaxExtra
                Dim result As KartrisNameValuePair = _Formulas.Find(AddressOf FindName)
                If result IsNot Nothing Then
                    strCorrectFormula = result.Value
                Else
                    Throw New Exception("Invalid D_TaxExtra Value: " & D_TaxExtra)
                End If
            Else
                'D_TaxExtra is empty so just get the "default" Formula
                strCorrectFormula = _Formulas.Item(0).Value
            End If

        Else
            'D_TaxExtra is empty so just get the "default" Formula
            strCorrectFormula = _Formulas.Item(0).Value
        End If


        'Boolean tax fields should only be either 1 or 0 
        If _DTax_Type.ToLower = "boolean" AndAlso D_Tax > 0 Then D_Tax = 1
        If _DTax2_Type.ToLower = "boolean" AndAlso D_Tax2 > 0 Then D_Tax2 = 1

        'V_Tax fields should always be converted to rate/percentage
        If _VTax_Type.ToLower = "boolean" AndAlso V_Tax > 0 Then V_Tax = 1 Else V_Tax = V_Tax / 100
        If _VTax2_Type.ToLower = "boolean" AndAlso V_Tax2 > 0 Then V_Tax2 = 1 Else V_Tax2 = V_Tax2 / 100

        'Replace the variables in the TaxRate Formula with the actual values
        strCorrectFormula = Replace(strCorrectFormula, "D_Tax2", D_Tax2)
        strCorrectFormula = Replace(strCorrectFormula, "V_Tax2", V_Tax2)
        strCorrectFormula = Replace(strCorrectFormula, "D_Tax", D_Tax)
        strCorrectFormula = Replace(strCorrectFormula, "V_Tax", V_Tax)


        Dim expr As String = String.Format(formula, strCorrectFormula)
        expr = expr.Replace(",", GetCurrenciesFromCache().Select("CUR_ID=" & HttpContext.Current.Session("CUR_ID"))(0)("CUR_DecimalPoint"))
        'this line does the actual computation
        Return CDec(tblCalculate.Compute(expr, ""))
    End Function

#Region "UTILITY CODE"
    ''' <summary>
    ''' generic Name Value Pair class
    ''' </summary>
    ''' <remarks></remarks>
    Class KartrisNameValuePair
        Public Property Name As String
        Public Property Value As String
    End Class
    ''' <summary>
    ''' Function to find a value in the Name property from a list
    ''' </summary>
    ''' <param name="Formula"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function FindName(ByVal Formula As KartrisNameValuePair) As Boolean
        If Formula.Name = _FormulaNameToFind Then
            Return True
        Else
            Return False
        End If
    End Function
#End Region
End Class