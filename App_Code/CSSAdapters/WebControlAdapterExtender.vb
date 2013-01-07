Imports System
Imports System.Data
Imports System.Collections
Imports System.Collections.Generic
Imports System.Configuration
Imports System.Reflection
Imports System.Web
Imports System.Web.Configuration
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.Adapters
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.Adapters
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls

Namespace Kartris
    Public Class WebControlAdapterExtender
        Private _adaptedControl As WebControl = Nothing
        Public ReadOnly Property AdaptedControl() As WebControl
            Get
                System.Diagnostics.Debug.Assert(Not IsNothing(_adaptedControl), "CSS Friendly adapters internal error", "No control has been defined for the adapter extender")
                Return _adaptedControl
            End Get
        End Property

        Public ReadOnly Property AdapterEnabled() As Boolean
            Get
                Dim bReturn As Boolean = True  ' normally the adapters are enabled

                '  Individual controls can use the expando property called AdapterEnabled
                '  as a way to turn the adapters off.
                '  <asp:TreeView runat="server" AdapterEnabled="false" />

                If ((Not IsNothing(AdaptedControl)) AndAlso _
                    (Not String.IsNullOrEmpty(AdaptedControl.Attributes("AdapterEnabled"))) AndAlso _
                    (AdaptedControl.Attributes("AdapterEnabled").IndexOf("false", StringComparison.OrdinalIgnoreCase) = 0)) Then
                    bReturn = False
                End If

                Return bReturn
            End Get
        End Property

        Private _disableAutoAccessKey As Boolean = False  ' used when dealing with things like read-only textboxes that should not have access keys
        Public ReadOnly Property AutoAccessKey() As Boolean
            Get
                '  Individual controls can use the expando property called AdapterEnabled
                '  as a way to turn on/off the heurisitic for automatically setting the AccessKey
                '  attribute in the rendered HTML.  The default is shown below in the initialization
                '  of the bReturn variable.
                '  <asp:TreeView runat="server" AutoAccessKey="false" />

                Dim bReturn As Boolean = True  ' by default, the adapter will make access keys are available
                If (_disableAutoAccessKey OrElse _
                    ((Not IsNothing(AdaptedControl)) AndAlso _
                     (Not String.IsNullOrEmpty(AdaptedControl.Attributes("AutoAccessKey"))) AndAlso _
                     (AdaptedControl.Attributes("AutoAccessKey").IndexOf("false", StringComparison.OrdinalIgnoreCase) = 0))) Then
                    bReturn = False
                End If

                Return bReturn
            End Get
        End Property

        Public Sub New(ByVal adaptedControl As WebControl)
            _adaptedControl = adaptedControl
        End Sub

        Public Sub RegisterScripts()
            Dim folderPath As String = WebConfigurationManager.AppSettings.Get("CSSFriendly-JavaScript-Path")
            If (String.IsNullOrEmpty(folderPath)) Then
                folderPath = "~/JavaScript"
            End If

            Dim filePath As String = IIf(folderPath.EndsWith("/"), folderPath & "AdapterUtils.js", folderPath & "/AdapterUtils.js")
            AdaptedControl.Page.ClientScript.RegisterClientScriptInclude(Me.GetType(), Me.GetType().ToString(), AdaptedControl.Page.ResolveUrl(filePath))
        End Sub

        Public Function ResolveUrl(ByVal url As String) As String
            Dim urlToResolve As String = url
            Dim nPound As Integer = url.LastIndexOf("#")
            Dim nSlash As Integer = url.LastIndexOf("/")
            If ((nPound > -1) AndAlso (nSlash > -1) AndAlso ((nSlash + 1) = nPound)) Then
                '  We have been given a somewhat strange URL.  It has a foreward slash (/) immediately followed
                '  by a pound sign (#) like this xxx/#yyy.  This sort of oddly shaped URL is what you get when
                '  you use named anchors instead of pages in the url attribute of a sitemapnode in an ASP.NET
                '  sitemap like this:
                '
                '  <siteMapNode url="#Introduction" title="Introduction"  description="Introduction" />
                '
                '  The intend of the sitemap author is clearly to create a link to a named anchor in the page
                '  that looks like these:
                '
                '  <a id="Introduction"></a>       (XHTML 1.1 Strict compliant)
                '  <a name="Introduction"></a>     (more old fashioned but quite common in many pages)
                '
                '  However, the sitemap interpretter in ASP.NET doesn't understand url values that start with
                '  a pound.  It prepends the current site's path in front of it before making it into a link
                '  (typically for a TreeView or Menu).  We'll undo that problem, however, by converting this
                '  sort of oddly shaped URL back into what was intended: a simple reference to a named anchor
                '  that is expected to be within the current page.

                urlToResolve = url.Substring(nPound)
            Else
                urlToResolve = AdaptedControl.ResolveClientUrl(urlToResolve)
            End If

            '  And, just to be safe, we'll make sure there aren't any troublesome characters in whatever URL
            '  we have decided to use at this point.
            Dim NewUrl As String = AdaptedControl.Page.Server.HtmlEncode(urlToResolve)

            Return NewUrl
        End Function

        Public Sub RaiseAdaptedEvent(ByVal eventName As String, ByVal e As EventArgs)
            Dim attr As String = "OnAdapted" + eventName
            If ((Not IsNothing(AdaptedControl)) AndAlso _
                (Not String.IsNullOrEmpty(AdaptedControl.Attributes(attr)))) Then
                Dim delegateName As String = AdaptedControl.Attributes(attr)
                Dim methodOwner As Control = AdaptedControl.Parent
                Dim method As MethodInfo = methodOwner.GetType().GetMethod(delegateName)
                If (IsNothing(method)) Then
                    methodOwner = AdaptedControl.Page
                    method = methodOwner.GetType().GetMethod(delegateName)
                End If
                If (Not IsNothing(method)) Then
                    Dim args() As Object = New Object(1) {}
                    args(0) = AdaptedControl
                    args(1) = e
                    method.Invoke(methodOwner, args)
                End If
            End If
        End Sub

        Public Sub RenderBeginTag(ByVal writer As HtmlTextWriter, ByVal cssClass As String)
            Dim id As String = ""
            If (Not IsNothing(AdaptedControl)) Then
                id = AdaptedControl.ClientID
            End If

            If (Not String.IsNullOrEmpty(AdaptedControl.Attributes("CssSelectorClass"))) Then
                WriteBeginDiv(writer, AdaptedControl.Attributes("CssSelectorClass"), id)
                id = ""
            End If

            WriteBeginDiv(writer, cssClass, id)
        End Sub

        Public Sub RenderEndTag(ByVal writer As HtmlTextWriter)
            WriteEndDiv(writer)

            If (Not String.IsNullOrEmpty(AdaptedControl.Attributes("CssSelectorClass"))) Then
                WriteEndDiv(writer)
            End If
        End Sub

        Public Shared Sub RemoveProblemChildren(ByVal ctrl As Control, ByVal stashedControls As List(Of ControlRestorationInfo))
            RemoveProblemTypes(ctrl.Controls, stashedControls)
        End Sub

        Public Shared Sub RemoveProblemTypes(ByVal coll As ControlCollection, ByVal stashedControls As List(Of ControlRestorationInfo))
            Dim ctrl As Control
            For Each ctrl In coll
                If ((TypeOf ctrl Is RequiredFieldValidator) OrElse _
                    (TypeOf ctrl Is CompareValidator) OrElse _
                    (TypeOf ctrl Is RegularExpressionValidator) OrElse _
                    (TypeOf ctrl Is ValidationSummary)) Then
                    Dim cri As ControlRestorationInfo = New ControlRestorationInfo(ctrl, coll)
                    stashedControls.Add(cri)
                    coll.Remove(ctrl)
                    Continue For
                End If

                If (ctrl.HasControls()) Then
                    RemoveProblemTypes(ctrl.Controls, stashedControls)
                End If
            Next
        End Sub

        Public Shared Sub RestoreProblemChildren(ByVal stashedControls As List(Of ControlRestorationInfo))
            Dim cri As ControlRestorationInfo
            For Each cri In stashedControls
                cri.Restore()
            Next
        End Sub

        Public Function MakeChildId(ByVal postfix As String) As String
            Return AdaptedControl.ClientID + "_" + postfix
        End Function

        Public Shared Function MakeNameFromId(ByVal id As String) As String
            Dim name As String = ""
            Dim i As Integer
            For i = 0 To id.Length - 1
                Dim thisChar As Char = id(i)
                Dim prevChar As Char = " "c
                If ((i - 1) > -1) Then
                    prevChar = id(i - 1)
                End If
                Dim nextChar As Char = " "c
                If ((i + 1) < id.Length) Then
                    nextChar = id(i + 1)
                End If
                If thisChar = "_"c Then
                    If prevChar = "_"c Then
                        name += "_"
                    ElseIf nextChar = "_"c Then
                        name += "$_"
                    Else
                        name += "$"
                    End If
                Else
                    name += thisChar
                End If
            Next
            Return name
        End Function

        Public Shared Function MakeIdWithButtonType(ByVal id As String, ByVal type As ButtonType) As String
            Dim idWithType As String = id
            Select Case type
                Case ButtonType.Button
                    idWithType &= "Button"
                    Exit Select
                Case ButtonType.Image
                    idWithType &= "ImageButton"
                    Exit Select
                Case ButtonType.Link
                    idWithType &= "LinkButton"
                    Exit Select
            End Select
            Return idWithType
        End Function

        Public Function MakeChildName(ByVal postfix As String) As String
            Return MakeNameFromId(MakeChildId(postfix))
        End Function

        Public Shared Sub WriteBeginDiv(ByVal writer As HtmlTextWriter, ByVal className As String, ByVal id As String)
            writer.WriteLine()
            writer.WriteBeginTag("div")
            If (Not String.IsNullOrEmpty(className)) Then
                writer.WriteAttribute("class", className)
            End If
            If (Not String.IsNullOrEmpty(id)) Then
                writer.WriteAttribute("id", id)
            End If
            writer.Write(HtmlTextWriter.TagRightChar)
            writer.Indent = writer.Indent + 1
        End Sub

        Public Shared Sub WriteEndDiv(ByVal writer As HtmlTextWriter)
            writer.Indent = writer.Indent - 1
            writer.WriteLine()
            writer.WriteEndTag("div")
        End Sub

        Public Shared Sub WriteSpan(ByVal writer As HtmlTextWriter, ByVal className As String, ByVal content As String)
            If (Not String.IsNullOrEmpty(content)) Then
                writer.WriteLine()
                writer.WriteBeginTag("span")
                If (Not String.IsNullOrEmpty(className)) Then
                    writer.WriteAttribute("class", className)
                End If
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Write(content)
                writer.WriteEndTag("span")
            End If
        End Sub

        Public Shared Sub WriteImage(ByVal writer As HtmlTextWriter, ByVal url As String, ByVal alt As String)
            If (Not String.IsNullOrEmpty(url)) Then
                writer.WriteLine()
                writer.WriteBeginTag("img")
                writer.WriteAttribute("src", url)
                writer.WriteAttribute("alt", alt)
                writer.Write(HtmlTextWriter.SelfClosingTagEnd)
            End If
        End Sub

        Public Shared Sub WriteLink(ByVal writer As HtmlTextWriter, ByVal className As String, ByVal url As String, ByVal title As String, ByVal content As String)
            If ((Not String.IsNullOrEmpty(url)) AndAlso (Not String.IsNullOrEmpty(content))) Then
                writer.WriteLine()
                writer.WriteBeginTag("a")
                If (Not String.IsNullOrEmpty(className)) Then
                    writer.WriteAttribute("class", className)
                End If
                writer.WriteAttribute("href", url)
                writer.WriteAttribute("title", title)
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Write(content)
                writer.WriteEndTag("a")
            End If
        End Sub

        '  Can't be static because it uses MakeChildId
        Public Sub WriteLabel(ByVal writer As HtmlTextWriter, ByVal className As String, ByVal text As String, ByVal forId As String)
            If (Not String.IsNullOrEmpty(text)) Then
                writer.WriteLine()
                writer.WriteBeginTag("label")
                writer.WriteAttribute("for", MakeChildId(forId))
                If (Not String.IsNullOrEmpty(className)) Then
                    writer.WriteAttribute("class", className)
                End If
                writer.Write(HtmlTextWriter.TagRightChar)

                If (AutoAccessKey) Then
                    writer.WriteBeginTag("em")
                    writer.Write(HtmlTextWriter.TagRightChar)
                    writer.Write(text(0).ToString())
                    writer.WriteEndTag("em")
                    If (Not String.IsNullOrEmpty(text)) Then
                        writer.Write(text.Substring(1))
                    End If
                Else
                    writer.Write(text)
                End If

                writer.WriteEndTag("label")
            End If
        End Sub

        '  Can't be static because it uses MakeChildId
        Public Sub WriteTextBox(ByVal writer As HtmlTextWriter, ByVal isPassword As Boolean, ByVal labelClassName As String, ByVal labelText As String, ByVal inputClassName As String, ByVal id As String, ByVal value As String)
            WriteLabel(writer, labelClassName, labelText, id)

            writer.WriteLine()
            writer.WriteBeginTag("input")
            writer.WriteAttribute("type", IIf(isPassword, "password", "text"))
            If (Not String.IsNullOrEmpty(inputClassName)) Then
                writer.WriteAttribute("class", inputClassName)
            End If
            writer.WriteAttribute("id", MakeChildId(id))
            writer.WriteAttribute("name", MakeChildName(id))
            writer.WriteAttribute("value", value)
            If (AutoAccessKey AndAlso (Not String.IsNullOrEmpty(labelText))) Then
                writer.WriteAttribute("accesskey", labelText(0).ToString().ToLower())
            End If
            writer.Write(HtmlTextWriter.SelfClosingTagEnd)
        End Sub

        '  Can't be static because it uses MakeChildId
        Public Sub WriteReadOnlyTextBox(ByVal writer As HtmlTextWriter, ByVal labelClassName As String, ByVal labelText As String, ByVal inputClassName As String, ByVal value As String)
            Dim oldDisableAutoAccessKey As Boolean = _disableAutoAccessKey
            _disableAutoAccessKey = True

            WriteLabel(writer, labelClassName, labelText, "")

            writer.WriteLine()
            writer.WriteBeginTag("input")
            writer.WriteAttribute("readonly", "readonly")
            If (Not String.IsNullOrEmpty(inputClassName)) Then
                writer.WriteAttribute("class", inputClassName)
            End If
            writer.WriteAttribute("value", value)
            writer.Write(HtmlTextWriter.SelfClosingTagEnd)

            _disableAutoAccessKey = oldDisableAutoAccessKey
        End Sub

        '  Can't be static because it uses MakeChildId
        Public Sub WriteCheckBox(ByVal writer As HtmlTextWriter, ByVal labelClassName As String, ByVal labelText As String, ByVal inputClassName As String, ByVal id As String, ByVal isChecked As Boolean)
            writer.WriteLine()
            writer.WriteBeginTag("input")
            writer.WriteAttribute("type", "checkbox")
            If (Not String.IsNullOrEmpty(inputClassName)) Then
                writer.WriteAttribute("class", inputClassName)
            End If
            writer.WriteAttribute("id", MakeChildId(id))
            writer.WriteAttribute("name", MakeChildName(id))
            If (isChecked) Then
                writer.WriteAttribute("checked", "checked")
            End If
            If (AutoAccessKey AndAlso (Not String.IsNullOrEmpty(labelText))) Then
                writer.WriteAttribute("accesskey", labelText(0).ToString().ToLower())
            End If
            writer.Write(HtmlTextWriter.SelfClosingTagEnd)

            WriteLabel(writer, labelClassName, labelText, id)
        End Sub

        '  Can't be static because it uses MakeChildId
        Public Sub WriteSubmit(ByVal writer As HtmlTextWriter, ByVal buttonType As ButtonType, ByVal className As String, ByVal id As String, ByVal imageUrl As String, ByVal javascript As String, ByVal text As String)
            writer.WriteLine()

            Dim idWithType As String = id

            Select Case buttonType
                Case buttonType.Button
                    writer.WriteBeginTag("input")
                    writer.WriteAttribute("type", "submit")
                    writer.WriteAttribute("value", text)
                    idWithType += "Button"
                    Exit Select
                Case buttonType.Image
                    writer.WriteBeginTag("input")
                    writer.WriteAttribute("type", "image")
                    writer.WriteAttribute("src", imageUrl)
                    idWithType += "ImageButton"
                    Exit Select
                Case buttonType.Link
                    writer.WriteBeginTag("a")
                    idWithType += "LinkButton"
                    Exit Select
            End Select

            If (Not String.IsNullOrEmpty(className)) Then
                writer.WriteAttribute("class", className)
            End If
            writer.WriteAttribute("id", MakeChildId(idWithType))
            writer.WriteAttribute("name", MakeChildName(idWithType))

            If (Not String.IsNullOrEmpty(javascript)) Then
                Dim pureJS As String = javascript
                If (pureJS.StartsWith("javascript:")) Then
                    pureJS = pureJS.Substring("javascript:".Length)
                End If
                Select Case buttonType
                    Case buttonType.Button
                        writer.WriteAttribute("onclick", pureJS)
                        Exit Select
                    Case buttonType.Image
                        writer.WriteAttribute("onclick", pureJS)
                        Exit Select
                    Case buttonType.Link
                        writer.WriteAttribute("href", javascript)
                        Exit Select
                End Select
            End If

            If (buttonType = buttonType.Link) Then
                writer.Write(HtmlTextWriter.TagRightChar)
                writer.Write(text)
                writer.WriteEndTag("a")
            Else
                writer.Write(HtmlTextWriter.SelfClosingTagEnd)
            End If
        End Sub

        Public Shared Sub WriteRequiredFieldValidator(ByVal writer As HtmlTextWriter, ByVal rfv As RequiredFieldValidator, ByVal className As String, ByVal controlToValidate As String, ByVal msg As String)
            If (Not IsNothing(rfv)) Then
                rfv.CssClass = className
                rfv.ControlToValidate = controlToValidate
                rfv.ErrorMessage = msg
                rfv.RenderControl(writer)
            End If
        End Sub

        Public Shared Sub WriteRegularExpressionValidator(ByVal writer As HtmlTextWriter, ByVal rev As RegularExpressionValidator, ByVal className As String, ByVal controlToValidate As String, ByVal msg As String, ByVal expression As String)
            If (Not IsNothing(rev)) Then
                rev.CssClass = className
                rev.ControlToValidate = controlToValidate
                rev.ErrorMessage = msg
                rev.ValidationExpression = expression
                rev.RenderControl(writer)
            End If
        End Sub

        Public Shared Sub WriteCompareValidator(ByVal writer As HtmlTextWriter, ByVal cv As CompareValidator, ByVal className As String, ByVal controlToValidate As String, ByVal msg As String, ByVal controlToCompare As String)
            If (Not IsNothing(cv)) Then
                cv.CssClass = className
                cv.ControlToValidate = controlToValidate
                cv.ErrorMessage = msg
                cv.ControlToCompare = controlToCompare
                cv.RenderControl(writer)
            End If
        End Sub

        Public Shared Sub WriteTargetAttribute(ByVal writer As HtmlTextWriter, ByVal targetValue As String)
            If ((Not IsNothing(writer)) AndAlso (Not String.IsNullOrEmpty(targetValue))) Then
                '  If the targetValue is _blank then we have an opportunity to use attributes other than "target"
                '  which allows us to be compliant at the XHTML 1.1 Strict level. Specifically, we can use a combination
                '  of "onclick" and "onkeypress" to achieve what we want to achieve when we used to render
                '  target='blank'.
                '
                '  If the targetValue is other than _blank then we fall back to using the "target" attribute.
                '  This is a heuristic that can be refined over time.
                If (targetValue.Equals("_blank", StringComparison.OrdinalIgnoreCase)) Then
                    Dim js As String = "window.open(this.href, '_blank', ''); return false;"
                    writer.WriteAttribute("onclick", js)
                    writer.WriteAttribute("onkeypress", js)
                Else
                    writer.WriteAttribute("target", targetValue)
                End If
            End If
        End Sub

    End Class



    Public Class ControlRestorationInfo
        Private _ctrl As Control = Nothing
        Public ReadOnly Property Control() As Control
            Get
                Return _ctrl
            End Get
        End Property

        Private _coll As ControlCollection = Nothing
        Public ReadOnly Property Collection() As ControlCollection
            Get
                Return _coll
            End Get
        End Property

        Public ReadOnly Property IsValid() As Boolean
            Get
                Return (Not IsNothing(Control)) AndAlso (Not IsNothing(Collection))
            End Get
        End Property

        Public Sub New(ByVal ctrl As Control, ByVal coll As ControlCollection)
            _ctrl = ctrl
            _coll = coll
        End Sub

        Public Sub Restore()
            If (IsValid) Then
                _coll.Add(_ctrl)
            End If
        End Sub
    End Class

End Namespace
