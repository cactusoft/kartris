'========================================================================
'Kartris - www.kartris.com
'Copyright 2013 CACTUSOFT INTERNATIONAL FZ LLC

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
Imports System.Threading
Imports System.Globalization
Imports System.Net.Mail
Imports System.Web.HttpContext
Imports System.Web.UI
Imports System.Text
Imports System.Xml

''' <summary>
''' Various types and values
''' Moved this to top in 1.4 as we need to
''' change version and issue date with every
''' release, so easier to find up here
''' </summary>
Public NotInheritable Class CkartrisEnumerations

    Public Const KARTRIS_VERSION As Decimal = 2.5
    Public Const KARTRIS_VERSION_ISSUE_DATE As Date = #6/9/2013# '' MM/dd/yyyy 

    Public Enum LANG_ELEM_TABLE_TYPE
        Versions = 1
        Products = 2
        Categories = 3
        Attributes = 4
        Options = 5
        OptionGroups = 6
        Promotions = 7
        Pages = 8
        ShippingMethods = 9
        ShippingZones = 10
        Destination = 11
        CustomerGroups = 12
        Currencies = 13
        AttributeValues = 14
        PromotionStrings = 15
        News = 16
        KnowledgeBase = 17
    End Enum

    Public Enum LANG_ELEM_FIELD_NAME
        Name = 1
        Description = 2
        PageTitle = 3
        MetaDescription = 4
        MetaKeywords = 5
        Text = 6
        StrapLine = 7
        URLName = 8
    End Enum

    Public Enum DML_OPERATION
        INSERT = 1
        UPDATE = 2
        DELETE = 3
    End Enum

    Public Enum ADMIN_LOG_TABLE
        Config = 1
        Currency = 2
        Languages = 3
        SiteText = 4
        Logins = 5
        DataRecords = 6
        ExecuteQuery = 7
        Triggers = 8
        Orders = 9
    End Enum

    Public Enum MESSAGE_TYPE
        Confirmation = 1
        ErrorMessage = 2
        Information = 3
    End Enum

    Public Enum SEARCH_TYPE
        classic = 1
        advanced = 2
    End Enum
End Class

Public NotInheritable Class CkartrisFormatErrors
    ''' <summary>
    ''' Log the errors
    ''' </summary>
    Public Shared Sub LogError(Optional ByVal strDescription As String = "")

        Dim blnCulturChanged As Boolean = False
        Dim strCurrentCulture As String = ""

        Try
            If HttpContext.Current.Session("KartrisUserCulture") IsNot Nothing Then strCurrentCulture = HttpContext.Current.Session("KartrisUserCulture").ToString
            Thread.CurrentThread.CurrentUICulture = New CultureInfo(LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID()))
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID()))
            blnCulturChanged = True
        Catch ex As Exception
            If strCurrentCulture <> "" Then
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(strCurrentCulture)
                Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(strCurrentCulture)
                blnCulturChanged = False
            End If
        End Try

        If GetKartConfig("general.errorlogs.enabled") = "y" Then
            Dim strErrorDescription As String

            If strDescription <> "" Then
                strErrorDescription = strDescription
            Else
                strErrorDescription = HttpContext.Current.Server.GetLastError.ToString()
            End If

            Dim strDirPath As String = ""
            Dim strFilePath As String = ""

            strDirPath = HttpContext.Current.Server.MapPath("~/" & ConfigurationManager.AppSettings("ErrorLogPath") & "/Errors/" & Format(Now, "yyyy.MM") & "/")
            strFilePath = strDirPath & CStr(Now.Year) & "." & Format(Now, "MM") & "." & Format(Now, "dd") & ".config"

            If Not Directory.Exists(strDirPath) Then Directory.CreateDirectory(strDirPath)

            Dim swtErrors As StreamWriter
            If Not File.Exists(strFilePath) Then
                swtErrors = File.CreateText(strFilePath)
            Else
                swtErrors = File.AppendText(strFilePath)
            End If

            swtErrors.WriteLine("-----------------------------------------------------------------------------")
            Try
                swtErrors.WriteLine(">>" & Space(5) & "Version:" & CkartrisEnumerations.KARTRIS_VERSION)
                swtErrors.WriteLine(">>" & Space(5) & "URL:" & HttpContext.Current.Request.Url.ToString)
                swtErrors.WriteLine(">>" & Space(5) & "Page:" & HttpContext.Current.Session("previous_page"))
            Catch ex As Exception

            End Try
            swtErrors.WriteLine("-----------------------------------------------------------------------------")
            swtErrors.WriteLine(">>" & Space(5) & Now.ToString())
            Try
                swtErrors.WriteLine(">>" & Space(5) & HttpContext.Current.Request.ServerVariables("REMOTE_ADDR"))
            Catch ex As Exception

            End Try
            swtErrors.WriteLine(">>" & Space(5) & "DESCRIPTION:")
            swtErrors.WriteLine(strErrorDescription)
            swtErrors.WriteLine("")
            swtErrors.WriteLine("==================================================")
            swtErrors.WriteLine("")
            swtErrors.WriteLine("")
            swtErrors.Flush()
            swtErrors.Close()
        End If

        If blnCulturChanged And Not String.IsNullOrEmpty(strCurrentCulture) Then
            Thread.CurrentThread.CurrentUICulture = New CultureInfo(strCurrentCulture)
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(strCurrentCulture)
        End If

        HttpContext.Current.Server.ClearError()

        If String.IsNullOrEmpty(strDescription) Then
            HttpContext.Current.Server.Transfer("~/Error.aspx")
        End If

    End Sub

    ''' <summary>
    ''' Report a handled error
    ''' </summary>
    Public Shared Sub ReportHandledError(ByVal _ex As Exception, ByVal _Source As Reflection.MethodBase, Optional ByRef _msg As String = "")
        Dim blnLogsEnabled As Boolean = True
        Try
            blnLogsEnabled = (GetKartConfig("general.errorlogs.enabled") = "y")
        Catch ex As Exception

        End Try

        If blnLogsEnabled Then
            Dim blnCulturChanged As Boolean = False, strCurrentCulture As String = ""
            Try
                strCurrentCulture = HttpContext.Current.Session("KartrisUserCulture").ToString
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID()))
                Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(LanguagesBLL.GetCultureByLanguageID_s(LanguagesBLL.GetDefaultLanguageID()))
                blnCulturChanged = True
            Catch ex As Exception
                If strCurrentCulture <> "" Then
                    Thread.CurrentThread.CurrentUICulture = New CultureInfo(strCurrentCulture)
                    Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(strCurrentCulture)
                    blnCulturChanged = False
                End If
            End Try
            Dim strDirPath As String = HttpContext.Current.Server.MapPath("~/" & ConfigurationManager.AppSettings("ErrorLogPath") & "/Errors/" & Format(Now, "yyyy.MM") & "/")
            Dim strFilePath As String = strDirPath & CStr(Now.Year) & "." & Format(Now, "MM") & "." & Format(Now, "dd") & ".config"

            If Not Directory.Exists(strDirPath) Then Directory.CreateDirectory(strDirPath)

            Dim swtErrors As StreamWriter
            If Not File.Exists(strFilePath) Then swtErrors = File.CreateText(strFilePath) Else swtErrors = File.AppendText(strFilePath)

            GenerateErrorMessage(_ex, _msg)

            swtErrors.WriteLine("-----------------------------------------------------------------------------")
            swtErrors.WriteLine(">>    " & _Source.ReflectedType.FullName & "." & _Source.Name)
            swtErrors.WriteLine("-----------------------------------------------------------------------------")
            swtErrors.WriteLine(">>    " & _ex.GetType.ToString())
            swtErrors.WriteLine(">>    " & Now.ToString())
            swtErrors.WriteLine(">>" & Space(5) & "Version:" & CkartrisEnumerations.KARTRIS_VERSION)
            swtErrors.WriteLine(">>" & Space(5) & "URL:" & HttpContext.Current.Request.Url.ToString)
            swtErrors.WriteLine(">>    " & HttpContext.Current.Request.ServerVariables("REMOTE_ADDR"))
            swtErrors.WriteLine(">>    CUSTOM MESSAGE:")
            swtErrors.WriteLine(_msg)
            Try
                swtErrors.WriteLine(">>    NUMBER:" & CType(_ex, SqlException).Number.ToString)
            Catch ex As Exception
            End Try
            swtErrors.WriteLine(">>    MESSAGE:")
            swtErrors.WriteLine(_ex.Message)
            swtErrors.WriteLine(">>    STACK:")
            swtErrors.WriteLine(_ex.StackTrace)
            swtErrors.WriteLine("==================================================")
            swtErrors.WriteLine("")
            swtErrors.WriteLine("")
            swtErrors.Flush()
            swtErrors.Close()

            If blnCulturChanged Then
                Thread.CurrentThread.CurrentUICulture = New CultureInfo(strCurrentCulture)
                Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(strCurrentCulture)
            End If
        End If
    End Sub

    ''' <summary>
    ''' Report an unhandled error
    ''' </summary>
    Public Shared Sub ReportUnHandledError()
        Dim blnLogsEnabled As Boolean = True
        Try
            blnLogsEnabled = (GetKartConfig("general.errorlogs.enabled") = "y")
        Catch ex As Exception

        End Try

        If blnLogsEnabled Then
            Dim strErrorDescription As String = HttpContext.Current.Server.GetLastError.ToString()
            Try
                If Not strErrorDescription.Contains("System.Security.Cryptography.RijndaelManagedTransform.DecryptData") Then
                    Dim strDirPath As String = ""
                    Dim strFilePath As String = ""

                    strDirPath = HttpContext.Current.Server.MapPath("~/" & ConfigurationManager.AppSettings("ErrorLogPath") & "/Errors/" & Format(Now, "yyyy.MM") & "/")
                    strFilePath = strDirPath & CStr(Now.Year) & "." & Format(Now, "MM") & "." & Format(Now, "dd") & ".config"

                    If Not Directory.Exists(strDirPath) Then Directory.CreateDirectory(strDirPath)

                    Dim swtErrors As StreamWriter
                    If Not File.Exists(strFilePath) Then
                        swtErrors = File.CreateText(strFilePath)
                    Else
                        swtErrors = File.AppendText(strFilePath)
                    End If

                    swtErrors.WriteLine("-----------------------------------------------------------------------------")
                    swtErrors.WriteLine(">>" & Space(5) & "Unhandled Error occurred in Page:" & System.Web.HttpContext.Current.Request.Url.ToString())
                    swtErrors.WriteLine("-----------------------------------------------------------------------------")
                    swtErrors.WriteLine(">>" & Space(5) & Now.ToString())
                    Try
                        swtErrors.WriteLine(">>" & Space(5) & "Version:" & CkartrisEnumerations.KARTRIS_VERSION)
                        swtErrors.WriteLine(">>" & Space(5) & "URL:" & HttpContext.Current.Request.Url.ToString)
                        swtErrors.WriteLine(">>" & Space(5) & HttpContext.Current.Request.ServerVariables("REMOTE_ADDR"))
                    Catch ex As Exception

                    End Try
                    swtErrors.WriteLine(">>" & Space(5) & "DESCRIPTION:")
                    swtErrors.WriteLine(strErrorDescription)
                    swtErrors.WriteLine("")
                    swtErrors.WriteLine("==================================================")
                    swtErrors.WriteLine("")
                    swtErrors.WriteLine("")
                    swtErrors.Flush()
                    swtErrors.Close()
                End If
            Catch ex As Exception
            End Try
        End If
    End Sub

    ''' <summary>
    ''' Generate an error message
    ''' </summary>
    Private Shared Sub GenerateErrorMessage(ByVal _ex As Exception, ByRef _msg As String)
        Select Case _ex.GetType.ToString
            Case "System.Data.SqlClient.SqlException"
                Dim ex As SqlException = CType(_ex, SqlException)
                Select Case ex.Number
                    Case 4060
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBAvailability")
                    Case 18456
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBAuthentication")
                    Case 10054
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBConnectivity")
                    Case 4929
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBChangeViolation")
                    Case 547
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBReferenceViolation")
                    Case 2627, 2601
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBDuplicateViolation")
                    Case 245
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBDataTypeViolation")
                    Case 229, 230, 262, 300
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBPermissionDenied")
                    Case 2812, 208
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBInvalidObject")
                    Case 201
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBValueNotSupplied")
                    Case 3609
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBObjectIsLocked")
                    Case Else
                        _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgDBGeneralError")
                End Select
            Case "System.ApplicationException"
                _msg += _ex.Message
            Case Else
                _msg += HttpContext.GetGlobalResourceObject("_Kartris", "ContentText_ErrorMsgGeneral")
        End Select
    End Sub
End Class

''' <summary>
''' Replace accented characters with non-accented equivalents
''' </summary>
Public NotInheritable Class CkartrisDisplayFunctions

    Public Shared Function ReplaceAccentedCharacters(ByVal strInput As String) As String
        strInput = Replace(strInput, "â", "a")
        strInput = Replace(strInput, "ã", "a")
        strInput = Replace(strInput, "ä", "a")
        strInput = Replace(strInput, "à", "a'")
        strInput = Replace(strInput, "á", "a'")
        strInput = Replace(strInput, "À", "A")
        strInput = Replace(strInput, "Á", "A")
        strInput = Replace(strInput, "Â", "A")
        strInput = Replace(strInput, "Ã", "A")
        strInput = Replace(strInput, "Ä", "A")
        strInput = Replace(strInput, "ê", "e")
        strInput = Replace(strInput, "ë", "e")
        strInput = Replace(strInput, "è", "e'")
        strInput = Replace(strInput, "é", "e'")
        strInput = Replace(strInput, "È", "E'")
        strInput = Replace(strInput, "É", "E'")
        strInput = Replace(strInput, "Ê", "E")
        strInput = Replace(strInput, "Ë", "E")
        strInput = Replace(strInput, "î", "i")
        strInput = Replace(strInput, "ï", "i")
        strInput = Replace(strInput, "ì", "i'")
        strInput = Replace(strInput, "í", "i'")
        strInput = Replace(strInput, "Ì", "I")
        strInput = Replace(strInput, "Í", "I")
        strInput = Replace(strInput, "Î", "I")
        strInput = Replace(strInput, "Ï", "I")
        strInput = Replace(strInput, "ô", "o")
        strInput = Replace(strInput, "õ", "o")
        strInput = Replace(strInput, "ö", "o")
        strInput = Replace(strInput, "ò", "o'")
        strInput = Replace(strInput, "ó", "o'")
        strInput = Replace(strInput, "Ò", "O")
        strInput = Replace(strInput, "Ó", "O")
        strInput = Replace(strInput, "Ô", "O")
        strInput = Replace(strInput, "Õ", "O")
        strInput = Replace(strInput, "Ö", "O")
        strInput = Replace(strInput, "ß", "ss")
        strInput = Replace(strInput, "û", "u")
        strInput = Replace(strInput, "ü", "u")
        strInput = Replace(strInput, "ù", "u'")
        strInput = Replace(strInput, "ú", "u'")
        strInput = Replace(strInput, "Ù", "U")
        strInput = Replace(strInput, "Ú", "U")
        strInput = Replace(strInput, "Û", "U")
        strInput = Replace(strInput, "Ü", "U")
        strInput = Replace(strInput, "ñ", "n")
        strInput = Replace(strInput, "Ý", "Y")
        strInput = Replace(strInput, "ý", "y")
        ReplaceAccentedCharacters = strInput
    End Function

    ''' <summary>
    ''' Clean up file names to ascii
    ''' </summary>
    Public Shared Function SanitizeProductName(ByVal strInput As String) As String
        strInput = Replace(strInput, " ", "e")
        Dim objRegex As RegularExpressions.Regex = New RegularExpressions.Regex("[^A-Za-z 0-9 \.,\?'""!@#\$%\^&\*\(\)-_=\+;:<>\/\\\|\}\{\[\]`~]*°")
        SanitizeProductName = objRegex.Replace(strInput, "")
    End Function

    ''' <summary>
    ''' Clean URL
    ''' </summary>
    Public Shared Function CleanURL(ByVal strInput As String) As String
        'will need to be replaced by a regex
        'strInput = strInput.Replace("""", "")
        'strInput = strInput.Replace("*", "")
        'strInput = strInput.Replace("#", "")
        strInput = strInput.Replace("//", "/")
        strInput = strInput.Replace("°", "o")
        strInput = strInput.Replace("./", "_/")

        'Return strInput.Replace("&", "-And-")

        Dim strArrayChars() As String = Split(""",',\,:,*,?,|,(,),%,#,&,>,<", ",")
        For numCount = 0 To UBound(strArrayChars)
            strInput = Replace(strInput, strArrayChars(numCount), IIf(strArrayChars(numCount) = "%", "pc", ""))
        Next
        Return strInput
    End Function

    ''' <summary>
    ''' This truncates descriptions to specified length if too long, and appends "..."
    ''' </summary>
    Public Shared Function TruncateDescription(ByVal strDescription As Object, ByVal numCharacters As Integer) As String
        strDescription = StripHTML(strDescription) 'uses another Kartris function

        If Len(strDescription) > numCharacters Then
            Return Left(strDescription, numCharacters) & "..."
        End If

        Return strDescription
    End Function

    ''' <summary>
    ''' This truncates display values on back end and adds "..."
    ''' </summary>
    Public Shared Function TruncateDescriptionBack(ByVal strDescription As Object, ByVal numCharacters As Integer) As String
        If Not String.IsNullOrEmpty(CkartrisDataManipulation.FixNullFromDB(strDescription)) Then
            If Len(strDescription) > numCharacters Then
                Return Left(strDescription, numCharacters) & "..."
            End If
        Else : Return ""
        End If
        Return strDescription
    End Function

    ''' <summary>
    ''' Strips HTML tags from text
    ''' </summary>
    Public Shared Function StripHTML(ByVal strInput As Object) As String
        Dim strOutput As String = ""
        Try
            strOutput = RegularExpressions.Regex.Replace(strInput.ToString, "<(.|\n)*?>", String.Empty)

            'This bit trims extra chars, probably because this function
            'was used incorrectly in some places to sanitize URLs - use CleanURL for that.
            'Dim strArrayChars() As String = Split("',/,\,:,*,?,|,(,),%", ",")
            'For numCount = 0 To UBound(strArrayChars)
            'strOutput = Replace(strOutput, strArrayChars(numCount), IIf(strArrayChars(numCount) = "%", "pc", ""))
            'Next

            'This removes half-formed tags with an opening < but no close tag
            If strOutput.Contains("<") Then
                strOutput = Left(strOutput, InStr(strOutput, "<") - 1)
            End If
        Catch
            strOutput = ""
        End Try

        Return strOutput
    End Function

    ''' <summary>
    ''' Format date strings
    ''' </summary>
    Public Shared Function FormatDate(ByVal datDate As DateTime, ByVal chrType As Char, ByVal numLanguageID As Byte) As String
        Dim strOutput As String = "-"
        Dim datOld As New Date(1982, 1, 1)
        If datDate < datOld Then
            strOutput = "-"
        Else
            Dim strFormat As String = LanguagesBLL.GetDateFormat(numLanguageID, chrType)
            Try
                strOutput = CDate(CkartrisDataManipulation.FixNullFromDB(datDate)).ToString(strFormat, _
                                                                                        CultureInfo.CreateSpecificCulture(CultureInfo.CurrentUICulture.TwoLetterISOLanguageName))
            Catch ex As Exception
                strOutput = Format(CkartrisDataManipulation.FixNullFromDB(datDate), strFormat)
            End Try
        End If

        Return strOutput
    End Function

    ''' <summary>
    ''' Format backward date strings
    ''' </summary>
    Public Shared Function FormatBackwardsDate(ByVal datDate As DateTime) As String
        Dim strOutput As String = "-"
        Dim datOld As New Date(1982, 1, 1)
        If datDate < datOld Then
            strOutput = "-"
        Else
            Dim strFormat As String = "yyyy/MM/dd"
            strOutput = Format(CkartrisDataManipulation.FixNullFromDB(datDate), strFormat)
        End If

        Return strOutput
    End Function

    ''' <summary>
    ''' Returns Kartris Shop Date
    ''' </summary>
    ''' <returns>Now + timeoffset config</returns>
    ''' <remarks></remarks>
    Public Shared Function NowOffset() As Date
        Return System.DateTime.Now.AddHours(CInt(GetKartConfig("general.timeoffset")))
    End Function

    Public Shared Function RemoveXSS(ByVal objText As Object) As Object
        If objText IsNot Nothing AndAlso objText.GetType() Is Type.GetType("System.String") Then
            objText = objText.Replace("<", "&lt;") '<
            objText = objText.Replace(">", "&gt;") '>
            objText = objText.Replace("'", "&apos;") 'apostophe
            objText = objText.Replace("""", "&#x22;") ' "
            objText = objText.Replace(")", "&#x29") ' )
            objText = objText.Replace("(", "&#x28") ' (
        End If
        Return objText
    End Function

End Class

''' <summary>
''' We can fix a number to be between certain ranges (e.g. zero and 100), if non-numeric, set as lower bound
''' </summary>
Public NotInheritable Class CkartrisDataManipulation
    Public Shared Function FixNumber(ByVal numInput As Object, ByVal numLowerBound As Double, ByVal numUpperBound As Double) As Double
        Dim numOutput As Double
        Try
            numOutput = Convert.ToDouble(numInput)
        Catch ex As Exception
            numOutput = 0
        End Try
        If numOutput > numUpperBound Then numOutput = numUpperBound
        If numOutput < numLowerBound Then numOutput = numLowerBound
        Return numOutput
    End Function

    ''' <summary>
    ''' If we expect strings but might get a Null, use this function on the value first
    ''' </summary>
    Public Shared Function FixNullToString(ByVal objInput As Object) As String
        Dim strOutput As String
        Try
            strOutput = Convert.ToString(objInput)
        Catch ex As Exception
            strOutput = ""
        End Try
        Return strOutput
    End Function

    ''' <summary>
    ''' If you want to INSERT or UPDATE the db, use this function which returns NULL for non-entered data fields.
    ''' </summary>
    ''' <param name="objInput">The data field that you want to check.</param>
    ''' <param name="chrType">The type of the data field.(s->String, i->Integer, b->Boolean, d->Double, and c->Char "</param>
    ''' <remarks>By Mohammad</remarks>
    Public Shared Function FixNullToDB(ByVal objInput As Object, Optional ByVal chrType As Char = "s") As Object
        Select Case chrType
            Case "s" 'String
                If objInput Is Nothing OrElse objInput = "" Then
                    Return DBNull.Value
                Else
                    Return CStr(objInput)
                End If
            Case "i" 'Integer
                If objInput Is Nothing OrElse objInput = 0 Then
                    'If objInput = 0 OrElse objInput Is Nothing Then
                    Return DBNull.Value
                Else
                    Return CInt(objInput)
                End If
            Case "b" 'Boolean
                If objInput Is Nothing Then
                    Return False
                Else
                    Return CBool(objInput)
                End If
            Case "d" 'Double
                If objInput Is Nothing Then
                    'If objInput = 0 OrElse objInput Is Nothing Then
                    Return DBNull.Value
                Else
                    Return CDbl(objInput)
                End If
            Case "c" 'Char
                If objInput = "" OrElse objInput Is Nothing Then
                    Return DBNull.Value
                Else
                    Return CChar(objInput)
                End If
            Case "g" 'Single
                If objInput Is Nothing OrElse objInput = 0.0 Then
                    'If objInput = 0 OrElse objInput Is Nothing Then
                    Return DBNull.Value
                Else
                    Return CSng(objInput)
                End If
            Case Else

        End Select
        Return objInput
    End Function

    ''' <summary>
    ''' If you are reading from the db, use this function which returns Nothing(the default value of the passed param.)
    '''  instead of having a DBNULL which in most cases, generates a run-time error.
    ''' </summary>
    ''' <param name="objInput">The datacolumn's value that you want to check</param>
    ''' <remarks>By Mohammad</remarks>
    Public Shared Function FixNullFromDB(ByVal objInput As Object) As Object
        If objInput Is DBNull.Value Then
            Return Nothing
        End If
        Return objInput
    End Function

    ''' <summary>
    ''' Handles the decimal point to be saved in the db as (dot)
    ''' </summary>
    Public Shared Function HandleDecimalValues(ByVal strValue As String) As Single
        Return Replace(strValue, ",", ".")
    End Function

    ''' <summary>
    ''' Handles the decimal point display in the backend
    ''' </summary>
    Public Shared Function _HandleDecimalValues(ByVal strValue As String) As String
        Dim strBackUserCulture As String = LanguagesBLL.GetCultureByLanguageID_s(CInt(Current.Session("_LANG")))
        Dim c As CultureInfo = New CultureInfo(strBackUserCulture)
        Return Replace(strValue, ".", c.NumberFormat.CurrencyDecimalSeparator)
    End Function

    ''' <summary>
    ''' Escape single quotes with two single quotes for SQL strings
    ''' DEPRECATED
    ''' </summary>
    Public Shared Function SQLSafe(ByVal strInput As String) As String
        SQLSafe = Replace(strInput, "'", "''")
        'SQLSafe = strInput 'DEPRECATED, set output to same as input
    End Function

    ''' <summary>
    ''' Get product ID from querystring
    ''' </summary>
    Public Shared Function _GetProductID() As Integer
        Dim numProductID As Integer = 0
        Try
            numProductID = CInt(HttpContext.Current.Request.QueryString("ProductID"))
        Catch ex As Exception
            numProductID = 0
        End Try

        Return numProductID

    End Function

    ''' <summary>
    ''' Get category ID from querystring
    ''' </summary>
    Public Shared Function _GetCategoryID() As Integer
        Dim numCategoryID As Integer = 0
        Try
            numCategoryID = CInt(HttpContext.Current.Request.QueryString("CategoryID"))
        Catch ex As Exception
            numCategoryID = 0
        End Try

        Return numCategoryID
    End Function

    ''' <summary>
    ''' Get parent categories from QueryString
    ''' </summary>
    Public Shared Function _GetParentCategory() As String
        Dim numParentCategoryIDs As String = ""
        Try
            numParentCategoryIDs = HttpContext.Current.Request.QueryString("strParent")
        Catch ex As Exception
            numParentCategoryIDs = ""
        End Try
        Return numParentCategoryIDs
    End Function

    ''' <summary>
    ''' Get a QueryString value from the current URL. Can be used to extract IDs and other numeric querystring values.
    ''' ** Integers only so don't use with querystrings that have decimal points!
    ''' </summary>
    ''' <param name="strQS"> The Query String parameter name you want to get.(e.g. ProductID,CategoryID)</param>
    ''' <remarks>Is this required? Ok. =) By Medz </remarks>
    Public Shared Function GetIntegerQS(ByVal strQS As String) As Integer
        Dim intID As Integer = 0
        Try
            intID = CInt(HttpContext.Current.Request.QueryString(strQS))
        Catch ex As Exception
            intID = 0
        End Try
        Return intID
    End Function

    ''' <summary>
    ''' Check it is a valid user agent
    ''' </summary>
    Public Shared Function IsValidUserAgent() As Boolean
        Try
            Dim strTemp As String = ConfigurationManager.AppSettings("ExcludedUserAgents").ToString()
            strTemp = strTemp.ToUpper()

            Dim strExcludedUserAgents() As String = New String() {""}
            strExcludedUserAgents = strTemp.Split(",")

            Dim strUserAgent As String
            strUserAgent = HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT").ToString()
            strUserAgent = strUserAgent.ToUpper()

            Dim i As Int32
            For i = 0 To strExcludedUserAgents.Length - 1
                If strUserAgent.Contains(strExcludedUserAgents(i)) Then
                    Return False
                End If
            Next
            Return True
        Catch ex As Exception
            Return False
        End Try
    End Function

    ''' <summary>
    ''' Create string of parameters for stored procedures
    ''' </summary>
    Public Shared Function CreateQuery(ByVal sqlCmd As SqlClient.SqlCommand) As String
        Dim sbdParameters As New StringBuilder("")
        Try
            sbdParameters.Append(sqlCmd.CommandText)
            For Each sqlParam As SqlParameter In sqlCmd.Parameters
                sbdParameters.Append("##" & sqlParam.ParameterName & "=" & FixNullToString(sqlParam.Value) & ",")
            Next
            If sbdParameters.ToString.EndsWith(",") Then Return sbdParameters.ToString.TrimEnd(",")
        Catch ex As Exception
            Return ""
        End Try

        Return sbdParameters.ToString
    End Function

    ''' <summary>
    ''' reads the category hierarchy again from the db
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub RefreshSiteMap()
        Dim _CatSiteMap As _CategorySiteMapProvider = DirectCast(SiteMap.Providers("_CategorySiteMapProvider"), _CategorySiteMapProvider)
        _CatSiteMap.ResetSiteMap()
        Dim CatSiteMap As CategorySiteMapProvider = DirectCast(SiteMap.Provider, CategorySiteMapProvider)
        CatSiteMap.RefreshSiteMap()
    End Sub
    ''' <summary>
    ''' Fetch the specified HTML Email Template from the currently used Skin
    ''' </summary>
    ''' <param name="strTemplateType"></param>
    ''' <param name="intLanguageID">Optional. Will get ID of the currently selected Language if not specified.</param>
    ''' <returns>returns a string variable that contains the content of the specified HTML template</returns>
    ''' <remarks></remarks>
    Public Shared Function RetrieveHTMLEmailTemplate(ByVal strTemplateType As String, Optional ByVal intLanguageID As Short = 0) As String
        Dim strEmailTemplateText As String = ""
        Dim strCulture As String = ""
        Dim strLanguage As String = ""
        Dim strSkinFolder As String = ""
        Dim strEmailTemplatePath_Culture As String = ""
        Dim strEmailTemplatePath_Language As String = ""

        'if language ID is not passed then retrieve the ID from session
        If intLanguageID = 0 Then
            intLanguageID = CkartrisBLL.GetLanguageIDfromSession
        End If

        'retrieve the culture, and derive the language code too
        strCulture = LanguagesBLL.GetCultureByLanguageID_s(intLanguageID) 'full culture, e.g. EN-GB
        strLanguage = Left(strCulture, 2) 'basic language part, e.g. EN

        'retrieve the currently used skin
        strSkinFolder = LanguagesBLL.GetTheme(intLanguageID)
        If String.IsNullOrEmpty(strSkinFolder) Then
            strSkinFolder = "Kartris"
        End If

        'This is where a culture-specific template would be found (e.g. EN-GB)
        strEmailTemplatePath_Culture = Current.Server.MapPath("~/Skins/" & strSkinFolder & "/Templates/Email_" &
                                        strTemplateType & "_" & strCulture & ".html")

        'This is where a general language template would be found (e.g. EN)
        strEmailTemplatePath_Language = Current.Server.MapPath("~/Skins/" & strSkinFolder & "/Templates/Email_" &
                                        strTemplateType & "_" & strLanguage & ".html")


        'We first look for exact culture template, if not found,
        'we look for a broader one for just the language
        If File.Exists(strEmailTemplatePath_Culture) Then

            'We have an exact culture match for template, e.g. EN-GB
            'This means you can have different templates for US and British
            'English, Portuguese from Portugal or Brazil, etc.
            Dim objFileStream As New FileStream(strEmailTemplatePath_Culture, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)
            Dim objStreamReader As New StreamReader(objFileStream)
            strEmailTemplateText = objStreamReader.ReadToEnd()
            objFileStream.Close()

        ElseIf File.Exists(strEmailTemplatePath_Language) Then

            'We have an basic culture match for template, e.g. EN 
            'This means we can use a single template for all
            'versions of English; most stores will probably want
            'to go this route for simplicity
            Dim objFileStream As New FileStream(strEmailTemplatePath_Language, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)
            Dim objStreamReader As New StreamReader(objFileStream)
            strEmailTemplateText = objStreamReader.ReadToEnd()
            objFileStream.Close()

        End If

        'strip out HTML comments in the template as we don't need them in the emails
        strEmailTemplateText = Regex.Replace(strEmailTemplateText, "<!--(.|\s)*?-->", String.Empty)

        Return strEmailTemplateText
    End Function
    ''' <summary>
    ''' Send email
    ''' </summary>
    Public Shared Function SendEmail(ByVal strFrom As String, ByVal strTo As String, ByVal strSubject As String, ByVal strBody As String, _
               Optional ByVal strReplyTo As String = "", Optional ByVal strFromName As String = "", _
                Optional ByVal sendEncoding As Encoding = Nothing, Optional ByVal strAttachment As String = "", _
               Optional ByVal blnSendAsHTML As Boolean = False, _
               Optional ByVal sendPriority As MailPriority = MailPriority.Normal, Optional ByVal objBCCAddress As MailAddressCollection = Nothing,
               Optional ByVal objAdditionalToAddresses As MailAddressCollection = Nothing) As Boolean
        Try
            If LCase(GetKartConfig("general.email.method")) = "write" Then
                'Write method - use javascript alert box to display email
                Dim pagCurrentPage As Page = HttpContext.Current.Handler
                If pagCurrentPage IsNot Nothing Then
                    Dim strBCCString As String = ""
                    If objBCCAddress IsNot Nothing Then
                        strBCCString = "BCC: "
                        For Each objItem As MailAddress In objBCCAddress
                            If strBCCString = "BCC: " Then
                                strBCCString += objItem.Address
                            Else
                                strBCCString += "; " & objItem.Address
                            End If
                        Next
                        strBCCString += "\n"
                    End If
                    'Do replacements so HTML will display properly in the JS alert popup
                    If blnSendAsHTML Then
                        strBody = "*HTML AND BODY TAGS are stripped when using WRITE emailmethod*" & vbCrLf &
                                     CkartrisBLL.ExtractHTMLBodyContents(strBody)
                    End If
                    strBody = strBody.Replace("\", "\\")
                    strBody = strBody.Replace("<", "\<")
                    strBody = strBody.Replace(">", "\>")
                    strBody = strBody.Replace("""", "\""")
                    strBody = strBody.Replace("'", "\'")
                    strBody = strBody.Replace("&", "\&")
                    strBody = strBody.Replace(vbCrLf, "\n")
                    strBody = strBody.Replace(vbLf, "\n")
                    Dim strBodyText As String = (String.Format("alert('FROM: " & strFrom & "\nTO: " & strTo & "\n" & strBCCString & _
                    "SUBJECT: " & strSubject & "\n\nBODY:\n {0}');", strBody))
                    ScriptManager.RegisterStartupScript(pagCurrentPage, pagCurrentPage.GetType, "WriteEmail", strBodyText, True)
                    'CurrentPage.ClientScript.RegisterStartupScript(CurrentPage.GetType, "WriteEmail", strBodyText, True)
                End If
            Else
                If LCase(GetKartConfig("general.email.method")) <> "off" Then
                    'Send the Email via the built in System.Net.Mail.SmtpClient
                    Dim objEmailFrom As MailAddress
                    If Not String.IsNullOrEmpty(strFromName) Then
                        objEmailFrom = New MailAddress(strFrom, strFromName)
                    Else
                        objEmailFrom = New MailAddress(strFrom)
                    End If
                    Dim objEmailTo As MailAddress = New MailAddress(strTo)
                    Dim objMailMessage As MailMessage = New MailMessage(objEmailFrom, objEmailTo)

                    objMailMessage.Subject = strSubject
                    objMailMessage.Body = strBody
                    If Not String.IsNullOrEmpty(strReplyTo) Then objMailMessage.ReplyToList.Add(New MailAddress(strReplyTo))
                    objMailMessage.BodyEncoding = IIf(sendEncoding Is Nothing, System.Text.Encoding.UTF8, sendEncoding)
                    objMailMessage.IsBodyHtml = blnSendAsHTML
                    objMailMessage.Priority = sendPriority

                    If objAdditionalToAddresses IsNot Nothing Then
                        For Each objItem As MailAddress In objAdditionalToAddresses
                            objMailMessage.To.Add(objItem)
                        Next
                    End If

                    If objBCCAddress IsNot Nothing Then
                        For Each objItem As MailAddress In objBCCAddress
                            objMailMessage.Bcc.Add(objItem)
                        Next
                    End If

                    If Not String.IsNullOrEmpty(strAttachment) Then
                        For Each strAttachmentPath As String In strAttachment.Split(",")
                            objMailMessage.Attachments.Add(New Attachment(strAttachmentPath))
                        Next
                    End If

                    Dim objMail As System.Net.Mail.SmtpClient = New System.Net.Mail.SmtpClient(GetKartConfig("general.email.mailserver"), CInt(GetKartConfig("general.email.smtpportnumber")))
                    Dim strUserName As String = GetKartConfig("general.email.smtpauthusername")
                    If Not String.IsNullOrEmpty(strUserName) Then
                        objMail.Credentials = New System.Net.NetworkCredential(strUserName, GetKartConfig("general.email.smtpauthpassword"))
                    End If
                    objMail.Send(objMailMessage)
                End If
            End If

            Return True
        Catch ex As Exception
            CkartrisFormatErrors.ReportHandledError(ex, System.Reflection.MethodBase.GetCurrentMethod)
            Return False
        End Try
        Return True
    End Function

    Public Shared Sub DownloadFile(ByVal strFileName As String)
        Dim strFilePath As String = Current.Server.MapPath(GetKartConfig("general.uploadfolder") & strFileName)
        Dim filTarget As System.IO.FileInfo = New System.IO.FileInfo(strFilePath)
        If filTarget.Exists Then
            Current.Response.Clear()
            Current.Response.AddHeader("Content-Disposition", "attachment; filename=" + Replace(strFileName, " ", "_"))
            Current.Response.AddHeader("Content-Length", filTarget.Length.ToString)
            Current.Response.ContentType = "application/octet-stream"
            Current.Response.TransmitFile(strFilePath)
            Current.Response.End()
        End If
    End Sub

    Public Shared Sub RemoveDownloadFiles(ByVal strFiles As String)
        If String.IsNullOrEmpty(strFiles) OrElse strFiles = "##" Then Return
        Dim arrFiles As String() = strFiles.Split("##")
        Dim strUploadPath As String = GetKartConfig("general.uploadfolder")
        For i As Integer = 0 To arrFiles.Length - 1
            Try
                If File.Exists(Current.Server.MapPath(strUploadPath & arrFiles(i))) Then
                    File.SetAttributes(Current.Server.MapPath(strUploadPath & arrFiles(i)), FileAttributes.Normal)
                    File.Delete(Current.Server.MapPath(strUploadPath & arrFiles(i)))
                End If
            Catch ex As Exception
            End Try
        Next
    End Sub
End Class

''' <summary>
''' Searching
''' </summary>
Public NotInheritable Class CKartrisSearchManager
    ''' <summary>
    ''' Create a cookie to store search prefs
    ''' </summary>
    Public Shared Sub CreateSearchCookie()
        If Current.Request.Cookies(HttpSecureCookie.GetCookieName("Search")) Is Nothing Then

            Dim cokSearch As New HttpCookie(HttpSecureCookie.GetCookieName("Search"))
            cokSearch.Values("exactPhrase") = ""
            cokSearch.Values("searchtype") = ""
            cokSearch.Values("keywords") = ""
            cokSearch.Values("searchMethod") = ""
            cokSearch.Values("minPrice") = ""
            cokSearch.Values("maxPrice") = ""

            Current.Response.Cookies.Add(cokSearch)

        End If
    End Sub

    ''' <summary>
    ''' Rewrite search cookie
    ''' </summary>
    Public Shared Function UpdateSearchCookie(ByVal strSearchedText As String, ByVal enumType As CkartrisEnumerations.SEARCH_TYPE, _
                              Optional ByVal strSearchMethod As String = Nothing, Optional ByVal sngMinPrice As Single = -1, Optional ByVal sngMaxPrice As Single = -1) As String
        Dim strKeywords As String = strSearchedText + ","
        strKeywords = ValidateSearchKeywords(strKeywords)

        If Not Current.Request.Cookies(HttpSecureCookie.GetCookieName("Search")) Is Nothing Then
            Dim cokSearch As New HttpCookie(HttpSecureCookie.GetCookieName("Search"))
            cokSearch.Values("exactPhrase") = Current.Server.UrlEncode(strSearchedText)
            cokSearch.Values("type") = enumType.ToString
            cokSearch.Values("keywords") = strKeywords
            cokSearch.Values("searchMethod") = IIf(String.IsNullOrEmpty(strSearchMethod), GetKartConfig("frontend.search.defaultmethod"), LCase(strSearchMethod))
            cokSearch.Values("minPrice") = sngMinPrice
            cokSearch.Values("maxPrice") = sngMaxPrice

            Current.Response.Cookies.Add(cokSearch)
        End If

        Return strKeywords
    End Function

    ''' <summary>
    ''' Exclude certain keywords from search
    ''' </summary>
    ''' <remarks>Each language can have its own set of excluded words, since we read them from language string</remarks>
    Public Shared Function ValidateSearchKeywords(ByVal strKeywords As String) As String

        Dim strInvalidKeywords As String = GetGlobalResourceObject("Kartris", "ContentText_ExcludedSearchKeywords")
        Dim sbdValidKeywords As New StringBuilder("")

        strKeywords = Replace(strKeywords, " ", ",")
        strKeywords = Replace(strKeywords, ",,", ",")

        'Escape single quotes as they seem to throw
        'errors if not
        strKeywords = Replace(strKeywords, "'", "''")

        Dim arrKeywords As String() = New String() {}
        arrKeywords = Split(strKeywords, ",")

        Dim arrInvalidKeywords As String() = New String() {}
        arrInvalidKeywords = Split(strInvalidKeywords, ",")

        For i As Integer = 0 To arrInvalidKeywords.GetUpperBound(0)
            For j As Integer = 0 To arrKeywords.GetUpperBound(0)
                If arrKeywords(j).Length = 1 Then
                    arrKeywords(j) = ""
                Else
                    If String.Compare(arrInvalidKeywords(i), arrKeywords(j), True) = 0 Then
                        arrKeywords(j) = ""
                    End If
                End If
            Next
        Next

        For i As Integer = 0 To arrKeywords.GetUpperBound(0)
            If arrKeywords(i) <> "" Then
                sbdValidKeywords.Append(arrKeywords(i))
                sbdValidKeywords.Append(",")
            End If
        Next

        If sbdValidKeywords.ToString.EndsWith(",") Then
            ''// 
            Dim strTemp As String = sbdValidKeywords.ToString.TrimEnd(",")
            sbdValidKeywords = New StringBuilder
            sbdValidKeywords.Append(strTemp)
        End If

        If sbdValidKeywords.ToString.StartsWith(",") Then
            sbdValidKeywords.Length = 0 : sbdValidKeywords.Capacity = 0
            sbdValidKeywords.Append(sbdValidKeywords.ToString.TrimStart(","))
        End If


        If GetKartConfig("") = "y" Then
            sbdValidKeywords.Length = 0 : sbdValidKeywords.Capacity = 0
            sbdValidKeywords.Append(CreateAllPossibleKeywords(sbdValidKeywords.ToString))
        End If

        Return sbdValidKeywords.ToString
    End Function

    ''' <summary>
    ''' Create list of all possible keyword combinations to run search
    ''' </summary>
    Private Shared Function CreateAllPossibleKeywords(ByVal pstrKeywords As String) As String
        Dim strKeywords As String = pstrKeywords
        strKeywords = strKeywords.Replace(" ", ",")

        Dim arrKeywords As String() = New String() {}
        arrKeywords = strKeywords.Split(",")

        Dim sbdNewKeys As New StringBuilder(""), sbdNewCombination As New StringBuilder("")

        For i As Integer = 0 To arrKeywords.GetUpperBound(0) - 1

            For k As Integer = 0 To arrKeywords.GetUpperBound(0) - i - 1
                sbdNewCombination.Length = 0 : sbdNewCombination.Capacity = 0
                sbdNewCombination.Append(arrKeywords(i))
                For j As Integer = i + 1 To arrKeywords.GetUpperBound(0) - k
                    sbdNewCombination.Append(" ")
                    sbdNewCombination.Append(arrKeywords(j))
                Next
                sbdNewKeys.Append(sbdNewCombination.ToString)
                sbdNewKeys.Append(",")
            Next

        Next

        Dim arrNewKeys(,) As String = New String(,) {}
        Dim arrDummyKeys As String() = New String() {}
        Dim sbdToPrint As New StringBuilder("")
        If sbdNewKeys.ToString.EndsWith(",") Then sbdNewKeys = New StringBuilder(sbdNewKeys.ToString.TrimEnd(","))
        arrDummyKeys = sbdNewKeys.ToString.Split(",")
        ReDim Preserve arrNewKeys(arrDummyKeys.Length - 1, 1)
        For i As Integer = 0 To arrDummyKeys.GetUpperBound(0)
            arrNewKeys(i, 0) = arrDummyKeys(i)
            arrNewKeys(i, 1) = arrDummyKeys(i).Length
        Next

        For i As Integer = 0 To arrNewKeys.GetUpperBound(0)
            For j As Integer = 0 To arrNewKeys.GetUpperBound(0) - 1
                Dim strTemp(,) As String = New String(1, 1) {}
                If CInt(arrNewKeys(j, 1)) < CInt(arrNewKeys(i, 1)) Then
                    strTemp(0, 0) = arrNewKeys(j, 0)
                    strTemp(0, 1) = arrNewKeys(j, 1)

                    arrNewKeys(j, 0) = arrNewKeys(i, 0)
                    arrNewKeys(j, 1) = arrNewKeys(i, 1)

                    arrNewKeys(i, 0) = strTemp(0, 0)
                    arrNewKeys(i, 1) = strTemp(0, 1)
                End If
            Next
        Next

        For i As Integer = 0 To arrNewKeys.GetUpperBound(0)
            sbdToPrint.Append(arrNewKeys(i, 0))
            sbdToPrint.Append(",")
        Next
        sbdToPrint.Append(strKeywords)

        Return sbdToPrint.ToString
    End Function

    Public Shared Function HighLightResultText(ByVal strContent As String, _
                            ByVal strKeywords As String) As String
        strContent = CkartrisDisplayFunctions.StripHTML(strContent)
        If String.IsNullOrEmpty(strContent) Then Return strContent

        'We use a temp pre/suffix to avoid the text of these
        'getting replaced themselves. For example, a search
        'for 'class' would replace class with a span tag, but
        'then the class attribute of that would itself get
        'replaced. No one is going to search for "[" or "[[".
        Dim strTempPrefix As String = "[[[[["
        Dim strTempSuffix As String = "]]]]]"

        Dim strPrefix As String = "<span class=""highlight"">"
        Dim strSuffix As String = "</span>"

        Dim sdbTextHighlight As New StringBuilder("")         ' A string builder that will hold the new value for each keyword
        Dim strNewKeywords As String() = New String() {""}    ' An array of strings that will contain the keywords
        strNewKeywords = strKeywords.Split(",")

        Dim numStartingIndex As Integer = 0
        Dim numKeywordLength As Integer = 0

        For i As Integer = 0 To strNewKeywords.Length - 1
            numStartingIndex = 0
            numKeywordLength = strNewKeywords(i).Length

            While numStartingIndex >= 0 AndAlso numStartingIndex < strContent.Length
                numStartingIndex = strContent.IndexOf(strNewKeywords(i), numStartingIndex, StringComparison.OrdinalIgnoreCase)
                If numStartingIndex <> -1 Then
                    sdbTextHighlight.Append(strTempPrefix)
                    sdbTextHighlight.Append(strContent.Substring(numStartingIndex, numKeywordLength))
                    sdbTextHighlight.Append(strTempSuffix)
                    strContent = Left(strContent, numStartingIndex) & sdbTextHighlight.ToString() & _
                        Mid(strContent, numStartingIndex + numKeywordLength + 1)
                    numStartingIndex += sdbTextHighlight.Length
                    sdbTextHighlight.Length = 0 : sdbTextHighlight.Capacity = 0 'Clear the content of the string builder to be used again
                End If
            End While
        Next

        'replace our highlight placeholder text [[[[[ with the
        'actual HTML tags (span) we want to use.
        strContent = Replace(strContent, strTempPrefix, strPrefix)
        strContent = Replace(strContent, strTempSuffix, strSuffix)

        Return strContent
    End Function

End Class

''' <summary>
''' Useful class to easily use the BLL Classes' Functionality
''' </summary>
Public NotInheritable Class CkartrisBLL

    ''' <summary>
    '''  Get the currently selected/active language id from session
    ''' </summary>
    ''' <remarks>returns the default language if we there's no session yet</remarks>
    Public Shared Function GetLanguageIDfromSession(Optional ByVal strWhere As String = "f") As Short
        Dim strLanguageSessionName As String
        If strWhere = "f" Then strLanguageSessionName = "LANG" Else strLanguageSessionName = "_LANG"
        If IsNothing(HttpContext.Current.Session) Then
            Return CShort(GetKartConfig("frontend.languages.default"))
        ElseIf String.IsNullOrEmpty(HttpContext.Current.Session.Item(strLanguageSessionName)) Then
            Return CShort(GetKartConfig("frontend.languages.default"))
        Else
            Return CInt(HttpContext.Current.Session.Item(strLanguageSessionName))
        End If
    End Function

    ''' <summary>
    ''' Try to refresh all the cache that Kartris uses.
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function RefreshKartrisCache() As Boolean
        'Clear caches we set programmatically
        Try
            RefreshCache()
            RefreshCurrencyCache()
            LanguagesBLL.GetLanguages(True) 'Refresh cache for the front end dropdown
            RefreshLanguagesCache()
            RefreshLETypesFieldsCache()
            RefreshTopListProductsCache()
            RefreshNewestProductsCache()
            RefreshFeaturedProductsCache()
            RefreshCustomerGroupsCache()
            RefreshSuppliersCache()
            RefreshTaxRateCache()
            RefreshSiteNewsCache()
            Dim CatSiteMap As CategorySiteMapProvider = DirectCast(SiteMap.Provider, CategorySiteMapProvider)
            CatSiteMap.RefreshSiteMap()
            LanguageStringProviders.Refresh()
            LoadSkinConfigToCache()
            For Each dicEntry As DictionaryEntry In HttpContext.Current.Cache
                HttpContext.Current.Cache.Remove(DirectCast(dicEntry.Key, String))
            Next
        Catch ex As Exception
            Return False
        End Try
        Return True
    End Function

    ''' <summary>
    ''' Restarts the whole Kartris Application. Requires either Full Trust (HttpRuntime.UnloadAppDomain) or Write access to web.config.
    ''' </summary>
    Public Shared Function RestartKartrisApplication() As Boolean
        Try
            HttpRuntime.UnloadAppDomain()
        Catch
            'unloading the appdomain failed - possibly because we're not running on full trust
            'try to modify the lastmodified attribute of the web.config file instead to trigger application restart.
            Try
                Dim ConfigPath As String = HttpContext.Current.Request.PhysicalApplicationPath + "\web.config"
                System.IO.File.SetLastWriteTimeUtc(ConfigPath, DateTime.UtcNow)
            Catch
                Return False
            End Try

        End Try
        Return True
    End Function

    ''' <summary>
    ''' Get the WebShopURL from config settings
    ''' </summary>
    Public Shared Function WebShopURL() As String
        Try
            'Check whether we need SSL or not.
            'Make sure we lowercase the entered domain as
            'otherwise this check is case sensitive, which
            'we don't want.
            If SSLHandler.IsSecuredForSEO() Or _
            (GetKartConfig("general.security.ssl") = "y" And HttpContext.Current.Request.Url.AbsoluteUri.ToLower.Contains("/admin/")) Or _
            (GetKartConfig("general.security.ssl") = "y" And HttpContext.Current.Request.Url.AbsoluteUri.ToLower.Contains("customeraccount.aspx")) Or _
            (GetKartConfig("general.security.ssl") = "y" And HttpContext.Current.Request.Url.AbsoluteUri.ToLower.Contains("checkout.aspx")) Or _
            (GetKartConfig("general.security.ssl") = "y" And HttpContext.Current.Request.Url.AbsoluteUri.ToLower.Contains("customertickets.aspx")) Then _
            Return Replace(GetKartConfig("general.webshopurl"), "http://", "https://")
        Catch ex As Exception
        End Try
        Return GetKartConfig("general.webshopurl")
    End Function

    ''' <summary>
    ''' Get the WebShop folder from config settings
    ''' </summary>
    Public Shared Function WebShopFolder() As String
        Return GetKartConfig("general.webshopfolder")
    End Function

    ''' <summary>
    ''' Find Skin
    ''' We use the term 'Theme' for legacy reasons.
    ''' (moved here from pagebaseclass as useful in places,
    ''' especially for linking to images such as 'not available')
    ''' </summary>
    Public Shared Function SkinMaster(ByVal objPage As System.Web.UI.Page, ByVal numLanguage As Integer) As String
        'We used a theme specified in the language record, if none
        'then use the default 'Kartris' one.
        Dim strSkinFolder As String = LanguagesBLL.GetTheme(numLanguage)
        Dim strMasterPage As String = LanguagesBLL.GetMasterPage(numLanguage)

        'If skin not set, use default
        If strSkinFolder = "" Then
            strSkinFolder = "Kartris"
        End If

        If objPage.MasterPageFile.ToLower.Contains("skins/kartris/template.master") Then
            'The .aspx page is set to use the defaults,
            'so we assume we either use skin specified in
            'back end, or the default.
            If Not String.IsNullOrEmpty(strMasterPage) Then
                'Have a master page specified in language
                'settings, use this
                SkinMaster = "~/Skins/" & strSkinFolder & "/" & strMasterPage
            Else
                'Use default skin
                SkinMaster = "~/Skins/" & strSkinFolder & "/Template.master"
            End If
        Else
            'Do nothing - we use the master page specified
            'in the .aspx page itself
            SkinMaster = ""
        End If

    End Function

    ''' <summary>
    ''' Find Skin in the Skins.Config file
    ''' We use the term 'Theme' for legacy reasons.
    ''' (moved here from pagebaseclass as useful in places,
    ''' especially for linking to images such as 'not available')
    ''' </summary>
    Public Shared Function SkinMasterConfig(ByVal objPage As System.Web.UI.Page, ByVal intProductID As Integer, ByVal intCategoryID As Integer, _
                                            ByVal intCustomerID As Integer, ByVal intCustomerGroupID As Integer, ByVal strScriptName As String) As String
        Dim strSkinFolder As String = ""

        Try
            If intCustomerID > 0 Then
                strSkinFolder = FindMatchingSkin("Customer", "", intCustomerID)
            End If

            If strSkinFolder = "" AndAlso intCustomerGroupID > 0 Then
                strSkinFolder = FindMatchingSkin("CustomerGroup", "", intCustomerGroupID)
            End If

            If strSkinFolder = "" AndAlso intProductID > 0 Then
                strSkinFolder = FindMatchingSkin("Product", "", intProductID)
            End If

            If strSkinFolder = "" AndAlso intCategoryID > 0 Then
                strSkinFolder = FindMatchingSkin("Category", "", intCategoryID)
            End If

            If strSkinFolder = "" AndAlso strScriptName <> "" Then
                strSkinFolder = FindMatchingSkin("Script", strScriptName, 0)
            End If

        Catch ex As Exception

        End Try

        If strSkinFolder <> "" Then
            Return "~/Skins/" & strSkinFolder & "/Template.master"
        Else
            Return ""
        End If
    End Function

    ''' <summary>
    ''' Find Skin
    ''' We use the term 'Theme' for legacy reasons.
    ''' (moved here from pagebaseclass as useful in places,
    ''' especially for linking to images such as 'not available')
    ''' </summary>
    Public Shared Function Skin(ByVal numLanguage As Integer) As String
        'We used a theme specified in the language record, if none
        'then use the default 'Kartris' one.
        Dim strSkin As String = LanguagesBLL.GetTheme(numLanguage)

        If Not String.IsNullOrEmpty(strSkin) Then
            Skin = strSkin
        Else
            Skin = "Kartris"
        End If
    End Function

    ''' <summary>
    ''' Load Skin config to cache
    ''' (if there is one)
    ''' </summary>
    Public Shared Sub LoadSkinConfigToCache()
        Try
            If File.Exists(Current.Server.MapPath("~/Skins/Skins.config")) Then
                Dim tblSkinRules As New DataTable
                tblSkinRules.Columns.Add("ScriptName", GetType(String))
                tblSkinRules.Columns.Add("Type", GetType(String))
                tblSkinRules.Columns.Add("ID", GetType(Integer))
                tblSkinRules.Columns.Add("SkinName", GetType(String))

                Dim docXML As XmlDocument = New XmlDocument
                docXML.Load(Current.Server.MapPath("~/Skins/Skins.Config"))

                ReadSkinRules(tblSkinRules, docXML, "Customer")
                ReadSkinRules(tblSkinRules, docXML, "CustomerGroup")
                ReadSkinRules(tblSkinRules, docXML, "Product")
                ReadSkinRules(tblSkinRules, docXML, "Category")
                ReadSkinRules(tblSkinRules, docXML, "Script")

                If HttpRuntime.Cache("tblSkinRules") IsNot Nothing Then HttpRuntime.Cache.Remove("tblSkinRules")

                HttpRuntime.Cache.Add("tblSkinRules", _
                         tblSkinRules, Nothing, Date.MaxValue, TimeSpan.Zero, _
                         Caching.CacheItemPriority.High, Nothing)
            End If
        Catch ex As Exception

        End Try
    End Sub

    ''' <summary>
    ''' Read skin rules
    ''' </summary>
    Private Shared Sub ReadSkinRules(ByRef tblSkinRules As DataTable, ByVal xmlDoc As XmlDocument, ByVal strType As String)
        Dim lstNodes As XmlNodeList
        Dim ndeRule As XmlNode

        Try
            lstNodes = xmlDoc.SelectNodes("/configuration/" & strType & "SkinRules/" & strType)

            'Loop through the nodes
            For Each ndeRule In lstNodes
                Dim drwRule As DataRow = tblSkinRules.NewRow
                drwRule("Type") = strType

                If strType.ToLower = "script" Then
                    drwRule("ScriptName") = ndeRule.Attributes.GetNamedItem("Name").Value
                    drwRule("ID") = 0
                Else
                    drwRule("ScriptName") = ""
                    drwRule("ID") = ndeRule.Attributes.GetNamedItem("ID").Value
                End If

                drwRule("SkinName") = ndeRule.Attributes.GetNamedItem("SkinName").Value
                tblSkinRules.Rows.Add(drwRule)
            Next
        Catch ex As Exception

        End Try

    End Sub

    ''' <summary>
    ''' Find skin that matches rules
    ''' </summary>
    Private Shared Function FindMatchingSkin(ByVal strType As String, ByVal strScriptname As String, ByVal intID As Integer) As String
        Dim tblSkinRules As DataTable = Nothing
        If HttpRuntime.Cache("tblSkinRules") Is Nothing Then
            LoadSkinConfigToCache()
        Else
            tblSkinRules = CType(HttpRuntime.Cache("tblSkinRules"), DataTable)
        End If

        Dim drwSkinRules As DataRow() = Nothing

        If strType.ToLower = "script" Then
            drwSkinRules = tblSkinRules.Select("ScriptName = '" & strScriptname & "' AND Type = '" & strType & "' ")
        Else
            drwSkinRules = tblSkinRules.Select("ID = " & intID & " AND Type = '" & strType & "' ")
        End If

        If drwSkinRules IsNot Nothing AndAlso drwSkinRules.Count > 0 Then
            For Each drwSkinRule As DataRow In drwSkinRules
                If strType.ToLower = "script" Then
                    If drwSkinRule("ScriptName").ToString.ToLower = strScriptname.ToLower Then
                        Return drwSkinRule("SkinName")
                    End If
                Else
                    If drwSkinRule("ID") = intID Then Return drwSkinRule("SkinName")
                End If
            Next
        End If
        Return ""
    End Function

    ''' <summary>
    ''' Format the 'items' section of order/confirmation emails
    ''' </summary>
    Public Shared Function GetItemEmailText(ByVal strName As String, ByVal strDescription As String, ByVal numExTax As Double, ByVal numIncTax As Double, ByVal numTaxAmount As Double, ByVal numTaxRate As Double, Optional ByVal CurrencyID As Integer = 0) As String
        Dim CUR_ID As Integer
        If CurrencyID > 0 Then
            CUR_ID = CurrencyID
        Else
            CUR_ID = CInt(HttpContext.Current.Session("CUR_ID"))
        End If

        Dim sbdItemEmailText As StringBuilder = New StringBuilder

        sbdItemEmailText.Append(GetGlobalResourceObject("Email", "EmailText_OrderEmailBreaker") & vbCrLf & " " & strName & vbCrLf)
        If strDescription <> "" Then sbdItemEmailText.Append(" " & strDescription & vbCrLf)
        If GetKartConfig("general.tax.pricesinctax") = "n" Or GetKartConfig("frontend.display.showtax") = "y" Then
            sbdItemEmailText.Append(" ")
            sbdItemEmailText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numExTax, , False))

            If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then
                sbdItemEmailText.Append(" + ")
                sbdItemEmailText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numTaxAmount, , False))
                sbdItemEmailText.Append(" ")
                sbdItemEmailText.Append(GetGlobalResourceObject("Kartris", "ContentText_Tax"))
                sbdItemEmailText.Append(" (")
                sbdItemEmailText.Append(numTaxRate * 100 & "%)")
            End If

            sbdItemEmailText.Append(vbCrLf)
        Else
            sbdItemEmailText.Append(" ")
            sbdItemEmailText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numIncTax, , False))
            sbdItemEmailText.Append(vbCrLf)
        End If
        Return sbdItemEmailText.ToString
    End Function

    ''' <summary>
    ''' Format the 'modifier' section of order/confirmation emails
    ''' </summary>
    Public Shared Function GetBasketModifierEmailText(ByVal objBasketModifier As BasketModifier, ByVal strName As String, ByVal strDescription As String, Optional ByVal CurrencyID As Integer = 0) As String
        With objBasketModifier
            GetBasketModifierEmailText = GetItemEmailText(strName, strDescription, .ExTax, .IncTax, .TaxAmount, .TaxRate, CurrencyID)
        End With
        Return GetBasketModifierEmailText
    End Function
    ''' <summary>
    ''' Format the table 'rows' section of order/confirmation HTML emails
    ''' </summary>
    Public Shared Function GetHTMLEmailRowText(ByVal strName As String, ByVal strDescription As String, ByVal numExTax As Double, ByVal numIncTax As Double, ByVal numTaxAmount As Double, ByVal numTaxRate As Double, Optional ByVal CurrencyID As Integer = 0) As String
        Dim CUR_ID As Integer
        If CurrencyID > 0 Then
            CUR_ID = CurrencyID
        Else
            CUR_ID = CInt(HttpContext.Current.Session("CUR_ID"))
        End If

        Dim sbdHTMLRowText As StringBuilder = New StringBuilder
        sbdHTMLRowText.Append("<tr class=""row_item""><td class=""col1"">")

        'Put the name and description on the first column
        sbdHTMLRowText.Append("<strong>" & strName & "</strong><br/>")
        If strDescription <> "" Then sbdHTMLRowText.Append(" " & strDescription.Replace(vbCrLf, "<br />") & "<br/>")

        sbdHTMLRowText.Append("</td><td class=""col2""> @ ")
        'Then put the price on the second
        If GetKartConfig("general.tax.pricesinctax") = "n" Or GetKartConfig("frontend.display.showtax") = "y" Then
            sbdHTMLRowText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numExTax, , False))

            If ConfigurationManager.AppSettings("TaxRegime").ToLower <> "us" Then
                sbdHTMLRowText.Append(" + ")
                sbdHTMLRowText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numTaxAmount, , False))
                sbdHTMLRowText.Append(" ")
                sbdHTMLRowText.Append(GetGlobalResourceObject("Kartris", "ContentText_Tax"))
                sbdHTMLRowText.Append(" (")
                sbdHTMLRowText.Append(numTaxRate * 100 & "%)")
            End If

            'sbdHTMLRowText.Append(vbCrLf)
        Else
            sbdHTMLRowText.Append(CurrenciesBLL.FormatCurrencyPrice(CUR_ID, numIncTax, , False))
            'sbdHTMLRowText.Append(vbCrLf)
        End If
        sbdHTMLRowText.Append("</td></tr>")
        Return sbdHTMLRowText.ToString
    End Function
    ''' <summary>
    ''' Format the 'modifier' section of order/confirmation HTML emails
    ''' </summary>
    Public Shared Function GetBasketModifierHTMLEmailText(ByVal objBasketModifier As BasketModifier, ByVal strName As String, ByVal strDescription As String, Optional ByVal CurrencyID As Integer = 0) As String
        With objBasketModifier
            GetBasketModifierHTMLEmailText = GetHTMLEmailRowText(strName, strDescription, .ExTax, .IncTax, .TaxAmount, .TaxRate, CurrencyID)
        End With
        Return GetBasketModifierHTMLEmailText
    End Function
    ''' <summary>
    ''' Extract the text inside <body></body> tags
    ''' </summary>
    Public Shared Function ExtractHTMLBodyContents(ByVal strHTML As String) As String
        'remove the opening body tag and anything before it
        strHTML = Mid(strHTML, strHTML.ToLower.IndexOf("<body>") + 7)
        'remove the closing body tag and anything after it
        strHTML = Left(strHTML, strHTML.ToLower.IndexOf("</body>"))

        'remove these template tags if present
        strHTML = strHTML.Replace("[poofflinepaymentdetails]", String.Empty)
        strHTML = strHTML.Replace("[storeowneremailheader]", String.Empty)
        Return strHTML
    End Function
    ''' <summary>
    ''' Get Google Checkout configuration
    ''' </summary>
    ''' <remarks>Google Checkout is a 'special case' gateway because of the way it handles whole checkout remotely</remarks>
    Public Shared Function GetGCheckoutConfig(ByVal strSettingName As String, Optional ByVal IsPO As Boolean = False) As String
        Dim objConfigFileMap As New ExeConfigurationFileMap()
        Dim blnIsProtected As Boolean = False
        If Not IsPO Then
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\GoogleCheckout\GoogleCheckout.dll.config")
        Else
            objConfigFileMap.ExeConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Plugins\PO_OfflinePayment\PO_OfflinePayment.dll.config")
        End If
        objConfigFileMap.MachineConfigFilename = Path.Combine(Current.Request.PhysicalApplicationPath, "Uploads\resources\Machine.Config")
        Dim objConfiguration As System.Configuration.Configuration = ConfigurationManager.OpenMappedExeConfiguration(objConfigFileMap, ConfigurationUserLevel.None)

        Dim objSectionGroup As ConfigurationSectionGroup = objConfiguration.GetSectionGroup("applicationSettings")
        Dim appSettingsSection As ClientSettingsSection = DirectCast(objSectionGroup.Sections.Item("Kartris.My.MySettings"), ClientSettingsSection)

        If appSettingsSection.Settings.Get("IsProtected").Value.ValueXml.InnerText.ToLower = "yes" Then blnIsProtected = True Else blnIsProtected = False

        If blnIsProtected Then
            Return Interfaces.Utils.Crypt(appSettingsSection.Settings.Get(strSettingName).Value.ValueXml.InnerText, _
                                          ConfigurationManager.AppSettings("HashSalt").ToString, _
                                        Interfaces.Utils.CryptType.Decrypt)
        Else
            Return appSettingsSection.Settings.Get(strSettingName).Value.ValueXml.InnerText
        End If

        Return Nothing
    End Function

    ''' <summary>
    ''' Push Kartris Notification to User Devices
    ''' </summary>
    ''' <param name="DataType"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function PushKartrisNotification(ByVal DataType As String) As String

        'send push notification requests if pushnotification config is enabled
        If GetKartConfig("general.pushnotifications.enabled") = "y" Then
            Try
                Dim DataValue As Long = 0
                If DataType.ToLower = "s" Then
                    Dim numUnassignedTickets As Integer, numAwaitingTickets As Integer
                    TicketsBLL._TicketsCounterSummary(numUnassignedTickets, numAwaitingTickets, 0)
                    DataValue = numUnassignedTickets
                ElseIf DataType.ToLower = "o" Then
                    DataValue = OrdersBLL._GetByStatusCount(OrdersBLL.ORDERS_LIST_CALLMODE.INVOICE)
                End If

                Dim svcNotifications As New com.kartris.livetile.Service1
                Dim KartrisNotification As New com.kartris.livetile.KartrisNotificationData

                Dim tblLoginsList As DataTable = LoginsBLL.GetLoginsList
                For Each dtLogin As DataRow In tblLoginsList.Rows
                    Dim strXML As String = CkartrisDataManipulation.FixNullFromDB(dtLogin.Item("LOGIN_PushNotifications"))
                    Dim blnLoginLive As Boolean = dtLogin.Item("LOGIN_Live")
                    If Not String.IsNullOrEmpty(strXML) AndAlso blnLoginLive Then
                        Dim xmlDoc As New XmlDocument
                        xmlDoc.LoadXml(strXML)
                        Dim xmlNodeList As XmlNodeList = xmlDoc.GetElementsByTagName("Device")
                        For Each node As XmlNode In xmlNodeList
                            'check first if the push notification device is set to live
                            If node.ChildNodes(3).InnerText.ToLower = "true" Then
                                With KartrisNotification
                                    .ClientWindowsStoreAppChannelURI = node.ChildNodes(2).InnerText
                                    'append device platform info to the notification type value
                                    .NotificationDataType = DataType & ":" & node.ChildNodes(1).InnerText
                                    .NotificationDataCount = DataValue
                                    .NotificationDataCountSpecified = True
                                    .KartrisWebShopURL = WebShopURL()
                                End With
                                svcNotifications.SendNotification(KartrisNotification)
                            End If
                        Next
                    End If
                Next
                Return "Success"
            Catch ex As Exception
                Return " - Error encountered while trying to send notification  - " & ex.Message
            End Try

        Else
            Return "NOT ENABLED"
        End If

    End Function
End Class

''' <summary>
''' Handle product combinations (all permutations of options for stock tracking)
''' </summary>
Public NotInheritable Class CkartrisCombinations

    Public Const MAX_NUMBER_OF_COMBINATIONS As Integer = 500 'paul changed to 500 for 1.4

    ''' <summary>
    ''' Easy way to tell difference between options and combinations product
    ''' </summary>
    Public Shared Function IsCombinationsProduct(ByVal numProductID As Double) As Boolean
        'Need to see if there are combinations, if not, this is a normal options product
        Dim tblCurrentCombinations As New DataTable
        tblCurrentCombinations = VersionsBLL._GetCombinationsByProductID(numProductID)

        If tblCurrentCombinations.Rows.Count = 0 Then
            'No combinations, not a combinations product
            Return False
        Else
            'Has combinations, is a combinations product
            Return True
        End If
    End Function

    ''' <summary>
    ''' Return all possible permutations
    ''' </summary>
    Public Shared Function GetProductCombinations(ByVal pProductID As Integer, ByRef tblFinalResult As DataTable, ByVal pLanguageID As Byte) As Boolean

        Dim intProductID As Integer = pProductID

        Dim tblProductOptionGroups As New DataTable
        tblProductOptionGroups = OptionsBLL._GetOptionGroupsByProductID(intProductID)

        Dim tblProductMandatoryOptions As New DataTable
        Dim tblProductOptionalOptions As New DataTable

        Dim arrTblProductMandatoryOptions() As DataTable = New DataTable() {Nothing}
        Dim arrTblProductOptionalOptions() As DataTable = New DataTable() {Nothing}
        Dim arrTblProductOptionalOptionsCombinations() As DataTable = New DataTable() {Nothing}

        Dim intIndex As Integer = 0

        For Each row As DataRow In tblProductOptionGroups.Rows
            If CBool(row("P_OPTG_MustSelected")) Then
                tblProductMandatoryOptions = New DataTable
                tblProductMandatoryOptions = OptionsBLL._GetOptionsByProductAndGroup(intProductID, CInt(row("P_OPTG_OptionGroupID")), pLanguageID)

                '' Un-necessary columns should be removed from the table, these columns
                ''   came from the table that holds the records (from the DAL)
                tblProductMandatoryOptions.Columns.Remove("P_OPT_OptionID")
                tblProductMandatoryOptions.Columns.Remove("P_OPT_ProductID")
                tblProductMandatoryOptions.Columns.Remove("P_OPT_OrderByValue")
                tblProductMandatoryOptions.Columns.Remove("P_OPT_PriceChange")
                tblProductMandatoryOptions.Columns.Remove("P_OPT_WeightChange")
                tblProductMandatoryOptions.Columns.Remove("P_OPT_Selected")

                '' No need for the PrimaryKey
                tblProductMandatoryOptions.PrimaryKey = Nothing

                '' Redim the mandatory array to hold the new mandatory option
                intIndex = arrTblProductMandatoryOptions.GetUpperBound(0) + 1
                ReDim Preserve arrTblProductMandatoryOptions(intIndex)
                arrTblProductMandatoryOptions(intIndex - 1) = tblProductMandatoryOptions
            Else
                tblProductOptionalOptions = New DataTable
                tblProductOptionalOptions = OptionsBLL._GetOptionsByProductAndGroup(intProductID, CInt(row("P_OPTG_OptionGroupID")), pLanguageID)

                '' Un-necessary columns should be removed from the table, these columns
                ''   came from the table that holds the records (from the DAL)
                tblProductOptionalOptions.Columns.Remove("P_OPT_OptionID")
                tblProductOptionalOptions.Columns.Remove("P_OPT_ProductID")
                tblProductOptionalOptions.Columns.Remove("P_OPT_OrderByValue")
                tblProductOptionalOptions.Columns.Remove("P_OPT_PriceChange")
                tblProductOptionalOptions.Columns.Remove("P_OPT_WeightChange")
                tblProductOptionalOptions.Columns.Remove("P_OPT_Selected")

                '' No need for the PrimaryKey
                tblProductOptionalOptions.PrimaryKey = Nothing

                '' Redim the mandatory array to hold the new optional option
                intIndex = arrTblProductOptionalOptions.GetUpperBound(0) + 1
                ReDim Preserve arrTblProductOptionalOptions(intIndex)
                arrTblProductOptionalOptions(intIndex - 1) = tblProductOptionalOptions
            End If
        Next

        Dim tblMandatoryCombinations As New DataTable
        Dim tblOptionalCombinations As New DataTable

        If arrTblProductMandatoryOptions.GetUpperBound(0) > 0 Then
            tblMandatoryCombinations = arrTblProductMandatoryOptions(0).Copy()
        End If

        '' Creating the Mandatory Data
        For i As Integer = 1 To arrTblProductMandatoryOptions.GetUpperBound(0) - 1
            tblMandatoryCombinations = JoinTablesForCombination(arrTblProductMandatoryOptions(i), tblMandatoryCombinations).Copy()
        Next

        '' Creating the Optional Data
        For i As Integer = 0 To arrTblProductOptionalOptions.GetUpperBound(0) - 1
            tblOptionalCombinations.Merge(arrTblProductOptionalOptions(i))
        Next
        For i As Integer = 0 To arrTblProductOptionalOptions.GetUpperBound(0) - 1
            If Not _
                RecursiveOptionalCombinations(tblOptionalCombinations, i, _
                                              arrTblProductOptionalOptions(i), arrTblProductOptionalOptions) Then
                Return False
            End If
        Next

        '' Merging the Manadatory & Optional data together, & produce the final result.
        tblFinalResult = New DataTable
        If tblMandatoryCombinations.Rows.Count > 0 Then   '' If the options contain a manditory options to select
            tblFinalResult = tblMandatoryCombinations.Copy() '' Need to copy the Manditory Combinations 1st
            tblFinalResult.Merge(JoinTablesForCombination(tblOptionalCombinations, tblMandatoryCombinations, True))
        Else                                    '' If the options don't contain a manditory options to select
            tblFinalResult = tblOptionalCombinations
        End If

        tblProductOptionGroups.Dispose()
        tblProductOptionalOptions.Dispose()
        tblProductMandatoryOptions.Dispose()
        tblOptionalCombinations.Dispose()
        tblMandatoryCombinations.Dispose()

        If tblFinalResult.Rows.Count > MAX_NUMBER_OF_COMBINATIONS Then Return False
        Return True

    End Function

    ''' <summary>
    ''' Recursive routine to create combinations
    ''' </summary>
    Shared Function RecursiveOptionalCombinations(ByRef tblResult As DataTable, ByVal intIndex As Integer, ByVal tblOptionalOption As DataTable, ByVal arrOptionalData() As DataTable) As Boolean
        If intIndex < arrOptionalData.GetUpperBound(0) - 1 Then
            Try
                For i As Integer = intIndex + 1 To arrOptionalData.GetUpperBound(0) - 1
                    Dim tblOriginal As DataTable = tblOptionalOption.Copy()
                    Dim tblJoinedData As DataTable = JoinTablesForCombination(arrOptionalData(i), tblOriginal).Copy()
                    tblResult.Merge(tblJoinedData)
                    If tblResult.Rows.Count > MAX_NUMBER_OF_COMBINATIONS Then Return False
                    If Not RecursiveOptionalCombinations(tblResult, i, tblJoinedData, arrOptionalData) Then Return False
                Next
            Catch ex As Exception
            End Try
        End If
        Return True
    End Function

    ''' <summary>
    ''' Do table joins using LINQ, returns result of join as table
    ''' </summary>
    Shared Function JoinTablesForCombination(ByVal tblNewData As DataTable, ByVal tblResult As DataTable, Optional ByVal useIDListForBoth As Boolean = False) As DataTable

        Dim tblTemp As New DataTable
        tblTemp = tblResult.Copy()

        '' CROSS JOIN by Language
        Dim tblJoinedResults = From a In tblNewData, b In tblTemp _
                    Select a, b

        tblResult.Rows.Clear()

        '' For each new Joined row .. it will be added to the result.
        For Each itmRow In tblJoinedResults
            Dim strID_List As String = itmRow.b("ID_List") & "," & itmRow.a("OPT_ID")
            If useIDListForBoth Then strID_List = itmRow.b("ID_List") & "," & itmRow.a("ID_List")
            tblResult.Rows.Add(Nothing, _
                            itmRow.b("OPT_Name") & "," & itmRow.a("OPT_Name"), _
                            itmRow.a("LANG_ID"), strID_List)
        Next

        Return tblResult
    End Function

End Class

''' <summary>
''' Handle images
''' </summary>
Public NotInheritable Class CkartrisImages

    Public Const strImagesPath As String = "~/Images/"
    Public Const strCategoryImagesPath As String = "~/Images/Categories"
    Public Const strProductImagesPath As String = "~/Images/Products"
    Public Const strPromotionImagesPath As String = "~/Images/Promotions"
    Public Const strThemesPath As String = "~/Skins"

    Public Enum IMAGE_TYPE
        enum_CategoryImage = 1
        enum_ProductImage = 2
        enum_VersionImage = 3
        enum_PromotionImage = 4
        enum_OtherImage = 5
    End Enum

    Public Enum IMAGE_SIZE
        enum_Thumb = 1
        enum_Normal = 2
        enum_Large = 3
        enum_Auto = 4
        enum_MiniThumb = 5
    End Enum

    ''' <summary>
    ''' Format URL to image folder
    ''' </summary>
    Public Shared Function CreateFolderURL(ByVal pImageType As IMAGE_TYPE, ByVal pItemID As String, Optional ByVal pParentID As String = "") As String

        Dim strFolderURL As String = "~/"

        Select Case pImageType
            Case IMAGE_TYPE.enum_CategoryImage
                strFolderURL &= "Images/Categories/" & pItemID & "/"
            Case IMAGE_TYPE.enum_ProductImage
                strFolderURL &= "Images/Products/" & pItemID & "/"
            Case IMAGE_TYPE.enum_VersionImage
                strFolderURL &= "Images/Products/" & pParentID & "/" & pItemID & "/"
            Case IMAGE_TYPE.enum_PromotionImage
                strFolderURL &= "Images/Promotions/" & pItemID & "/"
            Case Else

        End Select

        Return strFolderURL
    End Function

    ''' <summary>
    ''' Set image
    ''' </summary>
    Public Shared Sub SetImage(ByRef objImg As Object, _
                               ByVal eImgType As IMAGE_TYPE, _
                               ByVal strImageName As String, _
                               Optional ByVal eImgSize As IMAGE_SIZE = IMAGE_SIZE.enum_Auto, _
                               Optional ByVal blnSizeFromConfig As Boolean = False)

        Dim strImgPath As String = strImagesPath
        Dim strItemPlaceHolderConfig As String = ""
        strImgPath &= "Kartris/" & strImageName & ".gif"

        If eImgSize <> IMAGE_SIZE.enum_Auto AndAlso blnSizeFromConfig Then
            Dim stConfigKey As String = "frontend.display.images."
            Select Case eImgSize
                Case IMAGE_SIZE.enum_Thumb
                    stConfigKey &= "thumb"
                Case IMAGE_SIZE.enum_Normal
                    stConfigKey &= "normal"
                Case IMAGE_SIZE.enum_Large
                    stConfigKey &= "large"
                Case IMAGE_SIZE.enum_MiniThumb
                    strItemPlaceHolderConfig = "minithumb"
                    stConfigKey &= "minithumb"
                Case Else
                    stConfigKey = "thumb"
            End Select

            objImg.Width = New WebControls.Unit(GetKartConfig(stConfigKey & ".width"), WebControls.UnitType.Pixel)
            objImg.Height = New WebControls.Unit(GetKartConfig(stConfigKey & ".height"), WebControls.UnitType.Pixel)
        End If

        If Not File.Exists(HttpContext.Current.Server.MapPath(strImgPath)) Then
            If KartSettingsManager.GetKartConfig("frontend.display.image." & strItemPlaceHolderConfig & ".placeholder") = "y" Then
                strImgPath = strThemesPath & "/" & CkartrisBLL.Skin(Current.Session("LANG")) & "/Images/no_image_available.png"
            Else
                objImg.Visible = False
                Exit Sub
            End If
        End If

        Try
            objImg.ImageUrl = strImgPath
            objImg.Visible = True
        Catch ex As System.Exception
            'objImg.Visible = False
            'Exit Sub
        End Try


    End Sub

    ''' <summary> 
    ''' Finds a control recursively. Note: finds the first match that exists 
    ''' </summary> 
    ''' <remarks>Medz</remarks>
    Public Shared Function FindControlRecursive(ByVal ctlParentContainerID As Control, ByVal ctlControlIDToFind As String) As Control
        If ctlParentContainerID.ID = ctlControlIDToFind Then
            Return ctlParentContainerID
        End If

        For Each ctlChild As Control In ctlParentContainerID.Controls
            Dim ctlFound As Control = FindControlRecursive(ctlChild, ctlControlIDToFind)

            If ctlFound IsNot Nothing Then
                Return ctlFound
            End If
        Next
        Return Nothing
    End Function

    ''' <summary>
    ''' Remove/delete an image
    ''' </summary>
    Public Shared Sub RemoveImages(ByVal pImageType As IMAGE_TYPE, ByVal pItemID As String, Optional ByVal pParentID As String = "")

        Dim strFolderURL As String = "~/"

        Select Case pImageType
            Case IMAGE_TYPE.enum_CategoryImage
                strFolderURL += "Images/Categories/" & pItemID & "/"
            Case IMAGE_TYPE.enum_ProductImage
                strFolderURL += "Images/Products/" & pItemID & "/"
            Case IMAGE_TYPE.enum_VersionImage
                strFolderURL += "Images/Products/" & pParentID & "/" & pItemID & "/"
            Case IMAGE_TYPE.enum_PromotionImage
                strFolderURL += "Images/Promotions/" & pItemID & "/"
            Case Else

        End Select

        If Directory.Exists(HttpContext.Current.Server.MapPath(strFolderURL)) Then
            If Not HttpContext.Current.Application("isMediumTrust") Then
                Directory.Delete(HttpContext.Current.Server.MapPath(strFolderURL), True)
            Else
                Dim filInfo() As FileInfo
                Dim dirInfo As New DirectoryInfo(HttpContext.Current.Server.MapPath(strFolderURL))
                filInfo = dirInfo.GetFiles()
                For i As Integer = 0 To filInfo.Length - 1
                    filInfo(i).Delete()
                Next
                Directory.Delete(HttpContext.Current.Server.MapPath(strFolderURL), True)
            End If
        End If
    End Sub

    ''' <summary>
    ''' Remove product related images
    ''' </summary>
    Public Shared Sub RemoveProductsRelatedImages()

        '' Delete the categories' images
        Dim dirCategories As New DirectoryInfo(HttpContext.Current.Server.MapPath(CkartrisImages.strCategoryImagesPath))
        If dirCategories.Exists Then
            For Each d As DirectoryInfo In dirCategories.GetDirectories()
                Try
                    Directory.Delete(HttpContext.Current.Server.MapPath(CkartrisImages.strCategoryImagesPath & "/" & d.Name), True)
                Catch ex As Exception
                End Try
            Next
        End If

        '' Delete the products' images
        Dim dirProducts As New DirectoryInfo(HttpContext.Current.Server.MapPath(CkartrisImages.strProductImagesPath))
        If dirProducts.Exists Then
            For Each d As DirectoryInfo In dirProducts.GetDirectories()
                Try
                    Directory.Delete(HttpContext.Current.Server.MapPath(CkartrisImages.strProductImagesPath & "/" & d.Name), True)
                Catch ex As Exception
                End Try
            Next
        End If

        '' Delete the promotions' images
        Dim dirPromotions As New DirectoryInfo(HttpContext.Current.Server.MapPath(CkartrisImages.strPromotionImagesPath))
        If dirPromotions.Exists Then
            For Each d As DirectoryInfo In dirPromotions.GetDirectories()
                Try
                    Directory.Delete(HttpContext.Current.Server.MapPath(CkartrisImages.strPromotionImagesPath & "/" & d.Name), True)
                Catch ex As Exception
                End Try
            Next
        End If
    End Sub

    ''' <summary>
    ''' compress images
    ''' </summary>
    Public Shared Sub CompressImage(ByVal strImagePath As String, ByVal numQuality As Long)
        Dim numMaxWidth As Integer = 1500, numMaxHeight As Integer = 1500
        Try
            Dim numImageNewWidth, numImageNewHeight As Integer

            Dim objImgOriginal As System.Drawing.Image
            objImgOriginal = System.Drawing.Image.FromFile(strImagePath)
            objImgOriginal.RotateFlip(System.Drawing.RotateFlipType.Rotate180FlipNone)
            objImgOriginal.RotateFlip(System.Drawing.RotateFlipType.Rotate180FlipNone)

            If objImgOriginal.Height / numMaxHeight < objImgOriginal.Width / numMaxWidth Then
                'Resize by width
                numImageNewWidth = numMaxWidth
                numImageNewHeight = objImgOriginal.Height / (objImgOriginal.Width / numMaxWidth)
            Else
                'Resize by height
                numImageNewHeight = numMaxHeight
                numImageNewWidth = objImgOriginal.Width / (objImgOriginal.Height / numMaxHeight)
            End If

            'If new height/width bigger than old ones, cancel
            If numImageNewHeight > objImgOriginal.Height Or numImageNewWidth > objImgOriginal.Width Then
                numImageNewHeight = objImgOriginal.Height
                numImageNewWidth = objImgOriginal.Width
            End If

            Dim objImgCompressed As System.Drawing.Image = objImgOriginal.GetThumbnailImage(numImageNewWidth, numImageNewHeight, Nothing, Nothing)
            objImgOriginal.Dispose()

            Dim Info = System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders()
            Dim Params = New System.Drawing.Imaging.EncoderParameters(1)
            Params.Param(0) = New System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, numQuality)

            objImgCompressed.Save(strImagePath, Info(1), Params)
            objImgCompressed.Dispose()

        Catch ex As Exception

        End Try
    End Sub
End Class

Public NotInheritable Class CkartrisMedia
    Shared strMediaFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"

    Public Shared Sub RemoveMedia(ByVal numMediaID As Integer)
        Dim filInfo() As FileInfo
        Dim dirInfo As New DirectoryInfo(HttpContext.Current.Server.MapPath(strMediaFolder))
        filInfo = dirInfo.GetFiles(numMediaID & ".*")
        For i As Integer = 0 To filInfo.Length - 1
            filInfo(i).Delete()
        Next
        filInfo = dirInfo.GetFiles(numMediaID & "_thumb.*")
        For i As Integer = 0 To filInfo.Length - 1
            filInfo(i).Delete()
        Next
    End Sub
End Class

''' <summary>
''' Taxes
''' </summary>
Public NotInheritable Class CkartrisTaxes
    Public Shared Function CalculateTax(ByVal pIncTaxPrice As Single, ByVal pTaxRate As Single) As Single
        Dim blnIncTax As Boolean '= IIf(GetKartConfig("general.tax.pricesinctax") = "y", True, False)
        Dim blnShowTax As Boolean '= IIf(GetKartConfig("frontend.display.showtax") = "y", True, False)

        If ConfigurationManager.AppSettings("TaxRegime").ToLower = "us" Then
            blnIncTax = False
            blnShowTax = False
        Else
            blnIncTax = GetKartConfig("general.tax.pricesinctax") = "y"
            blnShowTax = GetKartConfig("frontend.display.showtax") = "y"
        End If

        If blnShowTax Then
            If blnIncTax Then
                Dim snglTax As Single = pTaxRate
                Dim snglExTax As Single = 0.0F
                Dim snglIncTax As Single = pIncTaxPrice
                snglExTax = snglIncTax * (1 / (1 + (snglTax / 100)))

                Return snglExTax
            End If
        End If

        Return pIncTaxPrice
    End Function
End Class

''' <summary>
''' Create graphs
''' </summary>
Public NotInheritable Class CkartrisGraphs
    Public Shared Function StatGraph(ByVal numMaxScale As Double, ByVal numValue As Double) As String
        'Dim strGraph As String = ""
        Dim stbGraph As New StringBuilder("")
        Dim numPercentage As Integer
        Try
            numPercentage = CInt((numValue / numMaxScale) * 100)
        Catch ex As Exception
            numPercentage = 0
        End Try


        'Create graph containing div
        stbGraph.Append("<div class=""stat_container"">")
        stbGraph.Append("<div class=""stat_outside"">")
        stbGraph.Append("<div class=""stat_inside"" style=""width:" & numPercentage & "%"">")

        stbGraph.Append("</div>")
        stbGraph.Append("</div>")
        stbGraph.Append("</div>")

        Return stbGraph.ToString
    End Function
End Class

''' <summary>
''' CSV export
''' </summary>
Public NotInheritable Class CKartrisCSVExporter

    Private Shared FieldDelimiter As Char
    Private Shared StringDelimiter As Char

    ''' <summary>
    ''' Write to CSV
    ''' </summary>
    Public Shared Sub WriteToCSV(ByVal tblToExport As DataTable, ByVal strFileName As String, _
                                 ByVal intFieldDelimiter As Integer, ByVal intStringDelimiter As Integer)
        FieldDelimiter = IIf(intFieldDelimiter = 0, " ", Chr(intFieldDelimiter))
        StringDelimiter = IIf(intStringDelimiter = 0, "", Chr(intStringDelimiter))

        Dim strData As New StringBuilder("")
        strData.AppendLine(WriteColumnName(tblToExport.Columns))

        For Each row As DataRow In tblToExport.Rows
            strData.AppendLine(WriteDataInfo(tblToExport.Columns, row))
        Next

        Dim data() As Byte = System.Text.ASCIIEncoding.ASCII.GetBytes(strData.ToString)

        Current.Response.Clear()
        Current.Response.AddHeader("Content-Type", "application/Excel")
        Current.Response.AddHeader("Content-Disposition", "inline;filename=" & strFileName.Replace(" ", "_") & ".csv")
        Current.Response.AddHeader("Content-Length", data.Length.ToString)
        Current.Response.BinaryWrite(data)
        Current.Response.End()
        Current.Response.Flush()

    End Sub

    ''' <summary>
    ''' Write data
    ''' </summary>
    Private Shared Function WriteDataInfo(ByVal cols As DataColumnCollection, ByVal row As DataRow) As String
        Dim stbData As StringBuilder = New StringBuilder("")
        For Each col As DataColumn In cols
            AddDelimiter(CkartrisDataManipulation.FixNullFromDB(row(col.ColumnName)), stbData, col.DataType)
        Next
        Return stbData.ToString().TrimEnd(FieldDelimiter)
    End Function

    ''' <summary>
    ''' Write column name
    ''' </summary>
    Private Shared Function WriteColumnName(ByVal cols As DataColumnCollection) As String
        Dim columnNames As String = ""
        For Each col As DataColumn In cols
            If StringDelimiter = Nothing Then
                columnNames += col.ColumnName & FieldDelimiter
            Else
                columnNames += StringDelimiter & col.ColumnName & StringDelimiter & FieldDelimiter
            End If
        Next
        columnNames = columnNames.TrimEnd(FieldDelimiter)
        Return columnNames

    End Function

    ''' <summary>
    ''' Add separation delimiter
    ''' </summary>
    Private Shared Sub AddDelimiter(ByVal value As String, ByVal stbData As StringBuilder, ByVal colType As Type)
        If value IsNot Nothing AndAlso Not String.IsNullOrEmpty(value) Then
            Select Case colType.FullName
                Case "System.Int16", "System.Int32", "System.Int64", _
                 "System.Double", "System.Byte", "System.Single", "System.Boolean"
                    stbData.Append(value.Replace(FieldDelimiter, "/"))
                Case "System.String"
                    value = Replace(Replace(value, Chr(10), " "), Chr(13), " ")
                    If StringDelimiter = Nothing Then
                        stbData.Append(value.Replace(FieldDelimiter, "/"))
                    Else
                        stbData.Append(StringDelimiter & value.Replace(FieldDelimiter, "/") & StringDelimiter)
                    End If
                Case Else
                    If StringDelimiter = Nothing Then
                        stbData.Append(value.Replace(FieldDelimiter, "/"))
                    Else
                        stbData.Append(StringDelimiter & value.Replace(FieldDelimiter, "/") & StringDelimiter)
                    End If
            End Select
        End If
        stbData.Append(FieldDelimiter)
    End Sub
End Class

