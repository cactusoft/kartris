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
Imports System.IO
Imports CkartrisDataManipulation

Partial Class UserControls_Front_MediaGallery
    Inherits System.Web.UI.UserControl

    Private _ParentType As String
    Private _ParentID As Integer

    Private _strInlineJS As String

    ''' <summary>
    ''' Media Links Parent Type
    ''' </summary>
    ''' <value>Can either be 'p' or 'v'</value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property ParentType() As String
        Set(ByVal value As String)
            _ParentType = value
        End Set
        Get
            Return _ParentType
        End Get
    End Property


    ''' <summary>
    ''' Media Links Parent ID
    ''' </summary>
    ''' <value>Version or Product ID</value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Property ParentID() As Long
        Set(ByVal value As Long)
            _ParentID = value
        End Set
        Get
            Return _ParentID
        End Get
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim tblMediaLinks As DataTable
        If Not IsPostBack Then
            If _ParentID > 0 Then
                'retrieve all the links for this specific record - called by LoadProduct() in ProductView.ascx.vb & ????? in ProductVersions.ascx.vb
                tblMediaLinks = MediaBLL.GetMediaLinksByParent(_ParentID, _ParentType)

                If tblMediaLinks.Rows.Count > 0 Then
                    rptMediaLinks.DataSource = tblMediaLinks
                    'call databind to trigger rptMediaLinks_ItemDataBound() Sub
                    rptMediaLinks.DataBind()
                Else
                    'hide media gallery
                    phdMediaGallery.Visible = False
                End If
            End If
        End If
    End Sub

    Protected Sub rptMediaLinks_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles rptMediaLinks.ItemDataBound
        If e.Item.ItemType = ListItemType.AlternatingItem OrElse _
            e.Item.ItemType = ListItemType.Item Then

            Dim strWebShopURL As String = CkartrisBLL.WebShopURL

            Dim strIconLink As String

            Dim drvMediaLink As DataRowView = CType(e.Item.DataItem, DataRowView)

            'get this item's media type details
            Dim strMT_Extension As String = FixNullFromDB(drvMediaLink.Item("MT_Extension"))
            Dim blnisEmbedded As Boolean = CType(FixNullFromDB(drvMediaLink.Item("MT_Embed")), Boolean)
            Dim blnisInline As Boolean = CType(FixNullFromDB(drvMediaLink.Item("MT_Inline")), Boolean)
            Dim blnisDownloadable As Boolean
            Try
                blnisDownloadable = CType(drvMediaLink.Item("ML_isDownloadable"), Boolean)
            Catch ex As Exception
                blnisDownloadable = CType(FixNullFromDB(drvMediaLink.Item("MT_DefaultisDownloadable")), Boolean)
            End Try

            Dim intHeight As Integer = FixNullFromDB(drvMediaLink.Item("ML_Height"))
            Dim intWidth As Integer = FixNullFromDB(drvMediaLink.Item("ML_Width"))

            'get the default height and width from the media type if the item doesn't have its height and width set
            If intHeight = 0 Then
                intHeight = FixNullFromDB(drvMediaLink.Item("MT_DefaultHeight"))
            End If
            If intWidth = 0 Then
                intWidth = FixNullFromDB(drvMediaLink.Item("MT_DefaultWidth"))
            End If

            Dim strMT_IconFolder As String = "Images/MediaTypes/"
            Dim strMediaLinksFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"

            Dim intML_ID As Integer = drvMediaLink.Item("ML_ID")
            Dim strML_EmbedSource As String = FixNullFromDB(drvMediaLink.Item("ML_EmbedSource"))
            Dim strML_Type As String = FixNullFromDB(drvMediaLink.Item("ML_ParentType"))

            'Get thumbnail or media type icon
            strIconLink = GetThumbPath(intML_ID, strMT_Extension)

            Dim strML_EmbedSource1 As String = ""

            If String.IsNullOrEmpty(strML_EmbedSource) Then
                If strMT_Extension <> "html5video" Then
                    strML_EmbedSource = strWebShopURL & Replace(strMediaLinksFolder, "~/", "") & intML_ID & "." & strMT_Extension
                Else
                    strML_EmbedSource = strWebShopURL & Replace(strMediaLinksFolder, "~/", "") & intML_ID & ".mp4"
                    strML_EmbedSource1 = strWebShopURL & Replace(strMediaLinksFolder, "~/", "") & intML_ID & ".webm"
                End If
                If Not File.Exists(Server.MapPath(strML_EmbedSource.Replace(strWebShopURL, "~/"))) Then
                    e.Item.Visible = False
                    CkartrisFormatErrors.LogError("Media File " & strML_EmbedSource & " (product:" & _GetProductID() & ") is not found!")
                    Exit Sub
                End If
            End If


            If blnisInline Then
                Dim litInline As New Literal
                litInline.Text = "<div id='inline_" & intML_ID & "'>"

                'check if the media link item already contains the embed code
                If blnisEmbedded Then
                    'embed - just write it directly to the page
                    litInline.Text += strML_EmbedSource & "</div>"
                    CType(e.Item.FindControl("phdInline"), PlaceHolder).Controls.Add(litInline)
                Else
                    CType(e.Item.FindControl("phdInline"), PlaceHolder).Controls.Add(litInline)
                    'template is needed so load up the appropriate control
                    Dim UC_Media As UserControl = LoadControl("~/UserControls/MediaTemplates/" & strMT_Extension & ".ascx")
                    If UC_Media IsNot Nothing Then
                        UC_Media.Attributes.Add("Source", strML_EmbedSource)
                        UC_Media.Attributes.Add("Height", intHeight)
                        UC_Media.Attributes.Add("Width", intWidth)
                        If strMT_Extension = "html5video" Then UC_Media.Attributes.Add("WebM", strML_EmbedSource1)

                        'try to get if media link has its own set of parameters
                        Dim strParameters As String = FixNullFromDB(drvMediaLink.Item("ML_Parameters"))

                        'and get the default paramters from the media type if none
                        If String.IsNullOrEmpty(strParameters) Then
                            strParameters = FixNullFromDB(drvMediaLink.Item("MT_DefaultParameters"))
                        End If

                        'parse the parameters
                        'format: parameter1=value1;parameter2=value2;parameter3=value3
                        If Not String.IsNullOrEmpty(strParameters) Then
                            Dim arrParameters As String() = Split(strParameters, ";")

                            For x = 0 To UBound(arrParameters)
                                Dim arrParameter As String() = Split(arrParameters(x), "=")
                                If UBound(arrParameter) = 1 Then
                                    UC_Media.Attributes.Add(arrParameter(0), arrParameter(1))
                                End If
                            Next
                        End If
                    End If

                    'finally add the template to the placeholder
                    CType(e.Item.FindControl("phdInline"), PlaceHolder).Controls.Add(UC_Media)

                    'and close the inline div
                    Dim litInlineEnd As New Literal
                    litInlineEnd.Text = "</div>"
                    CType(e.Item.FindControl("phdInline"), PlaceHolder).Controls.Add(litInlineEnd)

                End If

            Else
                If blnisDownloadable Then
                    'Show media popup
                    Dim strMediaImageLink As String = "<img alt="""" class=""media_image"" src=""" & _
                                    strIconLink & """ />"

                    'Show download link
                    Dim lnkDownload As HyperLink = CType(e.Item.FindControl("lnkDownload"), HyperLink)
                    If lnkDownload IsNot Nothing Then
                        If blnisDownloadable Then
                            lnkDownload.Visible = True
                            lnkDownload.Text = strMediaImageLink
                            lnkDownload.NavigateUrl = strML_EmbedSource
                            lnkDownload.Target = "_blank"
                        Else
                            lnkDownload.Visible = False
                        End If
                    End If
                Else
                    'Show media popup
                    Dim strMediaImageLink As String = "<img alt="""" class=""media_image"" src=""" & _
                                    strIconLink & """ />"

                    CType(e.Item.FindControl("litMediaLink"), Literal).Text = "<a class = """ & intML_ID & """ href=""javascript:ShowMediaPopup('" & _
                                    intML_ID & "','" & strMT_Extension & "','" & _ParentID & "','" & _ParentType & "','" & intWidth & "','" & intHeight & "')"">" & _
                                    strMediaImageLink & "</a>"
                End If
            End If
        End If
    End Sub
    
    Function GetThumbPath(ByVal numMediaID As String, ByVal strMediaType As String) As String
        Dim strWebShopURL As String = CkartrisBLL.WebShopURL

        Dim strImagesFolder As String = KartSettingsManager.GetKartConfig("general.uploadfolder") & "Media/"
        Dim dirMediaImages As New DirectoryInfo(Server.MapPath(strImagesFolder))
        For Each objFile As FileInfo In dirMediaImages.GetFiles(numMediaID & "_thumb.*")
            Return Replace(strImagesFolder, "~/", strWebShopURL) & objFile.Name
        Next

        'Media Link doesn't have thumbnail so get the default media type icon
        strImagesFolder = "~/Images/MediaTypes/"
        Dim dirMediaIconImages As New DirectoryInfo(Server.MapPath(strImagesFolder))
        For Each objFile As FileInfo In dirMediaIconImages.GetFiles(strMediaType & ".*")
            Return Replace(strImagesFolder, "~/", strWebShopURL) & objFile.Name
        Next

        Return Nothing
    End Function
End Class
