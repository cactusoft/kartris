'========================================================================
'Kartris - www.kartris.com
'Copyright 2016 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Configuration
Imports System.Web
Imports System.Text 
Imports System.Web.Security 
Imports System.Globalization 
Imports System.Web.Compilation 
Imports System.Resources 
Imports System.Collections 
Imports System.Collections.Specialized
Imports System.Collections.Generic
Imports kartrisLanguageDataTableAdapters
Imports kartrisLanguageData

''' <summary>
''' uses the standard ResourceProviderFactory in .NET framework - here we're creating a class that inherits this
''' provider to get resources from Kartris Language Strings table instead from a physical resource file.
''' </summary>
Public NotInheritable Class SqlResourceProviderFactory
    Inherits ResourceProviderFactory

    Public Sub New()
    End Sub

    Public Overloads Overrides Function CreateGlobalResourceProvider(ByVal classKey As String) As IResourceProvider
        Return New SqlResourceProvider(Nothing, classKey)
    End Function

    Public Overloads Overrides Function CreateLocalResourceProvider(ByVal virtualPath As String) As IResourceProvider
        virtualPath = Path.GetFileName(virtualPath)
        Return New SqlResourceProvider(virtualPath, Nothing)
    End Function
    ' inner class 
    Public NotInheritable Class SqlResourceProvider
        Implements IResourceProvider
        Private _virtualPath As String
        Private _className As String
        Private _resourceCache As IDictionary


        Private Shared CultureNeutralKey As New Object()

        Public Sub New(ByVal virtualPath As String, ByVal className As String)
            _virtualPath = virtualPath
            _className = className
            Try
                LanguageStringProviders.LoadedProviders.Add(Me)
            Catch ex As Exception
                CkartrisBLL.RecycleAppPool()
            End Try

        End Sub

        Public Sub ClearResourceCache()
            ' *** Just force the resource manager to be completely reloaded
            Me._resourceCache.Clear()
        End Sub
        Private Function GetResourceCache(ByVal cultureName As String) As IDictionary
            Dim cultureKey As Object

            If cultureName IsNot Nothing Then
                cultureKey = cultureName
            Else
                cultureKey = CultureNeutralKey
            End If

            If _className = "RESETme" Then _resourceCache = Nothing
            If _resourceCache Is Nothing Then
                _resourceCache = New ListDictionary()
            End If

            Dim resourceDict As IDictionary = TryCast(_resourceCache(cultureKey), IDictionary)

            If resourceDict Is Nothing Then
                resourceDict = SqlResourceHelper.GetResources(_virtualPath, _className, cultureName, False, Nothing)
                _resourceCache(cultureKey) = resourceDict
            End If

            Return resourceDict
        End Function

        Private Function GetObject(ByVal resourceKey As String, ByVal culture As CultureInfo) As Object Implements IResourceProvider.GetObject
            Dim cultureName As String = Nothing
            If culture IsNot Nothing Then
                cultureName = culture.Name
            Else
                cultureName = CultureInfo.CurrentUICulture.Name
            End If



            Dim value As Object = GetResourceCache(cultureName)(resourceKey)
            If value Is Nothing Then
                ' resource is missing for current culture 
                SqlResourceHelper.AddResource(resourceKey, _virtualPath, _className, cultureName)
                value = GetResourceCache(Nothing)(resourceKey)
            End If

            If value Is Nothing Then
                ' the resource is really missing, no default exists 
                SqlResourceHelper.AddResource(resourceKey, _virtualPath, _className, String.Empty)
            End If

            Return value
        End Function

        Private ReadOnly Property ResourceReader() As IResourceReader Implements IResourceProvider.ResourceReader
            Get
                Return New SqlResourceReader(GetResourceCache(Nothing))
            End Get
        End Property

    End Class
    ' inner class 
    Private NotInheritable Class SqlResourceReader
        Implements IResourceReader
        Private _resources As IDictionary

        Public Sub New(ByVal resources As IDictionary)
            _resources = resources
        End Sub

        Private Function GetEnumerator1() As IDictionaryEnumerator Implements IResourceReader.GetEnumerator
            Return _resources.GetEnumerator()
        End Function


        Private Sub Close() Implements IResourceReader.Close
        End Sub

        Private Function GetEnumerator() As IEnumerator Implements IEnumerable.GetEnumerator
            Return _resources.GetEnumerator()
        End Function

        Private Sub Dispose() Implements IDisposable.Dispose
        End Sub
    End Class


End Class


Friend NotInheritable Class SqlResourceHelper
    Private Sub New()
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    Shared Sub New()
    End Sub

    Private Shared Function GetLangIDfromCulture(ByVal cultureName As String) As Integer
        Dim Adptr = New LanguagesTblAdptr
        'Return Adptr.GetLanguageIDByCulture_s(cultureName)
        Return LanguagesBLL.GetLanguageIDByCulture_s(cultureName)
    End Function

    ''' <summary>
    ''' Get Language String
    ''' </summary>

    Public Shared Function GetResources(ByVal virtualPath As String, ByVal className As String, ByVal cultureName As String, ByVal designMode As Boolean, ByVal serviceProvider As IServiceProvider) As IDictionary
        Dim Adptr = New LanguageStringsTblAdptr

        'Initialize KartrisCore connection string
        If String.IsNullOrEmpty(Adptr.Connection.ConnectionString) Then
            'My.Settings.Item("LanguageConnection") = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
            Adptr.Connection.ConnectionString = ConfigurationManager.ConnectionStrings("KartrisSQLConnection").ConnectionString
        End If

        Dim dtLanguageStrings As New LanguageStringsDataTable
        Dim drLanguageStrings As DataRow

        Dim LANG_ID As Short

        If Not [String].IsNullOrEmpty(cultureName) Then
            Try
                LANG_ID = GetLangIDfromCulture(cultureName)
            Catch ex As Exception
                LANG_ID = 1
            End Try
        Else
            LANG_ID = 1
        End If
        ' get resource values 
        If Not [String].IsNullOrEmpty(virtualPath) Then
            ' Get Local resources 
            Adptr.FillByVirtualPath(dtLanguageStrings, LANG_ID, virtualPath)
        ElseIf Not [String].IsNullOrEmpty(className) Then
            ' Get Global resources 
            Adptr.FillByClassName(dtLanguageStrings, LANG_ID, className)
        Else
            ' Neither virtualPath or className provided, unknown if Local or Global resource 
            Throw New Exception("SqlResourceHelper.GetResources() - virtualPath or className missing from parameters.")
        End If


        Dim resources As New ListDictionary()
        Try
            For Each drLanguageStrings In dtLanguageStrings.Rows
                If drLanguageStrings.Item("ls_value").ToString = "" OrElse _
                    drLanguageStrings.Item("ls_value").ToString Is Nothing Then
                    Dim strLsName As String = drLanguageStrings.Item("ls_name").ToString
                    resources.Add(drLanguageStrings.Item("ls_name").ToString, _
                                  "$_" & Right(strLsName, strLsName.Length - strLsName.IndexOf("_") - 1))
                Else
                    resources.Add(drLanguageStrings.Item("ls_name").ToString, drLanguageStrings.Item("ls_value").ToString)
                End If


            Next

        Catch e As Exception
            SqlConnection.ClearPool(Adptr.Connection)
            Throw New Exception(e.Message, e)
        Finally
        End Try
        Return resources
    End Function

    '''<summary>
    ''' New language string
    ''' </summary>
    Public Shared Sub AddResource(ByVal resource_name As String, ByVal virtualPath As String, ByVal className As String, ByVal cultureName As String)

        'Dim con As New SqlConnection(_connectionString)
        'Dim com As New SqlCommand()

        'Dim LANG_ID As Integer = 1
        'If Not [String].IsNullOrEmpty(cultureName) Then LANG_ID = GetLangIDfromCulture(cultureName)
        'If Not [String].IsNullOrEmpty(LANG_ID) Then LANG_ID = 1

        'Dim sb As New StringBuilder()
        'sb.Append("INSERT INTO tblKartrisLanguageStrings")
        ''sb.Append(LANG_ID)
        'sb.Append(" (LS_Name ,LS_Value,LS_Classname,LS_LANGID) ")
        'sb.Append(" VALUES (@resource_name ,@resource_value,@resource_object,@LANG_ID) ")
        'com.CommandText = sb.ToString()
        'com.Parameters.AddWithValue("@resource_name", resource_name)
        'com.Parameters.AddWithValue("@resource_value", resource_name + " * DEFAULT * " + (IIf([String].IsNullOrEmpty(cultureName), String.Empty, cultureName)))
        'com.Parameters.AddWithValue("@culture_name", (IIf([String].IsNullOrEmpty(cultureName), SqlString.Null, cultureName)))
        'com.Parameters.AddWithValue("@LANG_ID", LANG_ID)
        'Dim resource_object As String = "UNKNOWN **ERROR**"
        'If Not [String].IsNullOrEmpty(virtualPath) Then
        '    resource_object = virtualPath
        'ElseIf Not [String].IsNullOrEmpty(className) Then
        '    resource_object = className
        'End If
        'com.Parameters.AddWithValue("@resource_object", resource_object)


        'Try
        '    com.Connection = con
        '    con.Open()
        '    com.ExecuteNonQuery()
        'Catch e As Exception
        '    Throw New Exception(e.ToString())
        'Finally
        '    If con.State = ConnectionState.Open Then
        '        con.Close()
        '    End If
        'End Try

    End Sub
End Class
Public Class LanguageStringProviders
    ''' <summary>
    ''' Keep track of loaded providers so we can unload them
    ''' </summary>
    Friend Shared LoadedProviders As New List(Of SqlResourceProviderFactory.SqlResourceProvider)()

    ''' <summary>
    ''' Allow unloading of all loaded providers
    ''' </summary>
    Public Shared Sub Refresh()
        For Each provider As SqlResourceProviderFactory.SqlResourceProvider In LoadedProviders
            provider.ClearResourceCache()
        Next
    End Sub
End Class
Public Interface SqlResourceProvider
    ''' <summary>
    ''' Interface method used to force providers to register themselves
    ''' with LanguageStringProviders.LoadProviders
    ''' </summary>
    Sub ClearResourceCache()
End Interface
