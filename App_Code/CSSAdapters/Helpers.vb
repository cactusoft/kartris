Imports System
Imports System.Collections
Imports System.Reflection
Imports System.Web.UI
Imports System.Web.Configuration
Imports System.Web.UI.WebControls
Imports System.Web.UI.HtmlControls

Namespace Kartris
    ''' <summary>
    ''' Provides static helper methods to CSSFriendly controls. Singleton instance.
    ''' </summary>
    Public Class Helpers
        ''' <summary>
        ''' Private constructor forces singleton.
        ''' </summary>
        Private Sub New()
        End Sub

        Public Shared Function GetListItemIndex(ByVal control As ListControl, ByVal item As ListItem) As Integer
            Dim index As Integer = control.Items.IndexOf(item)
            If index = -1 Then
                Throw New NullReferenceException("ListItem does not exist ListControl.")
            End If

            Return index
        End Function

        Public Shared Function GetListItemClientID(ByVal control As ListControl, ByVal item As ListItem) As String
            If control Is Nothing Then
                Throw New ArgumentNullException("Control can not be null.")
            End If

            Dim index As Integer = GetListItemIndex(control, item)

            Return [String].Format("{0}_{1}", control.ClientID, index.ToString())
        End Function

        Public Shared Function GetListItemUniqueID(ByVal control As ListControl, ByVal item As ListItem) As String
            If control Is Nothing Then
                Throw New ArgumentNullException("Control can not be null.")
            End If

            Dim index As Integer = GetListItemIndex(control, item)

            Return [String].Format("{0}${1}", control.UniqueID, index.ToString())
        End Function

        Public Shared Function HeadContainsLinkHref(ByVal page As Page, ByVal href As String) As Boolean
            If page Is Nothing Then
                Throw New ArgumentNullException("page")
            End If

            For Each control As Control In page.Header.Controls
                If TypeOf control Is HtmlLink AndAlso TryCast(control, HtmlLink).Href = href Then
                    Return True
                End If
            Next

            Return False
        End Function

        Public Shared Sub RegisterEmbeddedCSS(ByVal css As String, ByVal type As Type, ByVal page As Page)
            Dim filePath As String = page.ClientScript.GetWebResourceUrl(type, css)

            ' if filePath is not empty, embedded CSS exists -- register it
            If Not [String].IsNullOrEmpty(filePath) Then
                If Not Helpers.HeadContainsLinkHref(page, filePath) Then
                    Dim link As New HtmlLink()
                    link.Href = page.ResolveUrl(filePath)
                    link.Attributes("type") = "text/css"
                    link.Attributes("rel") = "stylesheet"
                    page.Header.Controls.Add(link)
                End If
            End If
        End Sub

        Public Shared Sub RegisterClientScript(ByVal resource As String, ByVal type As Type, ByVal page As Page)
            Dim filePath As String = page.ClientScript.GetWebResourceUrl(type, resource)

            ' if filePath is empty, set to filename path
            If [String].IsNullOrEmpty(filePath) Then
                Dim folderPath As String = WebConfigurationManager.AppSettings.[Get]("CSSFriendly-JavaScript-Path")
                If [String].IsNullOrEmpty(folderPath) Then
                    folderPath = "~/JavaScript"
                End If
                filePath = IIf(folderPath.EndsWith("/"), folderPath + resource, folderPath + "/" + resource)
            End If

            If Not page.ClientScript.IsClientScriptIncludeRegistered(type, resource) Then
                page.ClientScript.RegisterClientScriptInclude(type, resource, page.ResolveUrl(filePath))
            End If
        End Sub

        ''' <summary>
        ''' Gets the value of a non-public field of an object instance. Must have Reflection permission.
        ''' </summary>
        ''' <param name="container">The object whose field value will be returned.</param>
        ''' <param name="fieldName">The name of the data field to get.</param>
        ''' <remarks>Code initially provided by LonelyRollingStar.</remarks>
        Public Shared Function GetPrivateField(ByVal container As Object, ByVal fieldName As String) As Object
            Dim type As Type = container.[GetType]()
            Dim fieldInfo As FieldInfo = type.GetField(fieldName, BindingFlags.NonPublic Or BindingFlags.Instance)
            Return (IIf(fieldInfo Is Nothing, Nothing, fieldInfo.GetValue(container)))
        End Function
        ' Replicates the functionality of the internal Page.EnableLegacyRendering property
        Public Shared Function EnableLegacyRendering() As Boolean
            ' 2007-10-02: The following commented out code will NOT work in Medium Trust environments
            'Configuration cfg = WebConfigurationManager.OpenWebConfiguration(HttpContext.Current.Request.ApplicationPath);
            'XhtmlConformanceSection xhtmlSection = (XhtmlConformanceSection) cfg.GetSection("system.web/xhtmlConformance");

            'return xhtmlSection.Mode == XhtmlConformanceMode.Legacy;


            ' 2007-10-02: The following work around, provided by Michael Tobisch, works in
            ' Medium Trust by directly reading the Web.config file as XML.
            Dim result As Boolean

            Try
                Dim webConfigFile As String = Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "web.config")
                Dim webConfigReader As New XmlTextReader(New StreamReader(webConfigFile))
                result = ((webConfigReader.ReadToFollowing("xhtmlConformance")) AndAlso (webConfigReader.GetAttribute("mode") = "Legacy"))
                webConfigReader.Close()
            Catch
                result = False
            End Try
            Return result
        End Function
    End Class
End Namespace

