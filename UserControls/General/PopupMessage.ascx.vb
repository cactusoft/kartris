'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class UserControls_General_PopupMessage
    Inherits System.Web.UI.UserControl

    Enum POPUP_TYPE
        TEXT = 1
        IMAGE = 2
        PANEL = 3
        MEDIA = 4
    End Enum

    Private _Title As String
    Private _TextMessage As String
    Private _ImagePath As String
    Private _MediaPath As String
    Private _HideCancel As Boolean
    Private _PopupType As POPUP_TYPE

    Public WriteOnly Property SetTitle() As String
        Set(ByVal value As String)
            _Title = value
        End Set
    End Property

    Public WriteOnly Property SetImagePath() As String
        Set(ByVal value As String)
            _PopupType = POPUP_TYPE.IMAGE
            _ImagePath = value
        End Set
    End Property

    Public WriteOnly Property SetMediaPath() As String
        Set(ByVal value As String)
            _PopupType = POPUP_TYPE.MEDIA
            _MediaPath = value
        End Set
    End Property

    Public WriteOnly Property SetTextMessage() As String
        Set(ByVal value As String)
            _PopupType = POPUP_TYPE.TEXT
            _TextMessage = value
        End Set
    End Property

    Public WriteOnly Property SetPanel() As Panel
        Set(ByVal value As Panel)
            _PopupType = POPUP_TYPE.PANEL
            value.Visible = True
            updPopup.ContentTemplateContainer.Controls.Remove(pnlMessage)
            updPopup.ContentTemplateContainer.Controls.Add(value)
            popMessage.PopupControlID = value.ID
        End Set
    End Property

    'We preload the popup so we can trigger it later
    'with javascript
    Public Sub PreLoadPopup(Optional ByVal pPnl As Panel = Nothing)
        If _PopupType = POPUP_TYPE.TEXT Then
            mvwDisplay.SetActiveView(viwText)
            litMessage.Text = _TextMessage
        ElseIf _PopupType = POPUP_TYPE.IMAGE Then
            'Create iframe

            litIframeLargeImage.Text &= "<iframe frameBorder=""0""" & vbCrLf
            litIframeLargeImage.Text &= " src=""" & CkartrisBLL.WebShopURL & "LargeImage.aspx" & vbCrLf
            litIframeLargeImage.Text &= "?P_ID=" & _ImagePath & """" & vbCrLf
            litIframeLargeImage.Text &= " width=""100%""" & vbCrLf
            litIframeLargeImage.Text &= " height=""100%""" & vbCrLf
            litIframeLargeImage.Text &= " class=""iframe""" & vbCrLf
            litIframeLargeImage.Text &= "></iframe>" & vbCrLf

            'Actually we should use an object tag. This is now
            'preferred in 'strict' xhtml, syntax is slightly
            'different too, but similar. Problem is that Opera
            'seems to choke on it, and does not display anything 
            'for the object below. So we reverted to iframe as
            'above. But will keep this here so hopefully one
            'day we can set this compliant code free.

            'litIframeLargeImage.Text &= "<object type=""text/html"" " & vbCrLf
            'litIframeLargeImage.Text &= " data=""" & CkartrisBLL.WebShopURL & "LargeImage.aspx" & vbCrLf
            'litIframeLargeImage.Text &= "?P_ID=" & _ImagePath & """" & vbCrLf
            'litIframeLargeImage.Text &= " width=""100%""" & vbCrLf
            'litIframeLargeImage.Text &= " height=""100%""" & vbCrLf
            'litIframeLargeImage.Text &= " class=""iframe""" & vbCrLf
            'litIframeLargeImage.Text &= "></object>" & vbCrLf

            mvwDisplay.SetActiveView(viwImage)
            litMessage.Text = _ImagePath
        ElseIf _PopupType = POPUP_TYPE.PANEL Then
            'errrr.. nothing
        ElseIf _PopupType = POPUP_TYPE.MEDIA Then

            'Set the popup message to run a special javascript
            'function to clear up vids when cancelled. If not,
            'the video keeps playing even after the poup is closed
            'so you can hear video soundtrack carries on
            popMessage.OnCancelScript = "document.getElementById('media_iframe').src=''"

            'Create iframe
            litIframeMedia.Text &= "<input type=""hidden"" id=""media_iframe_base_url"" value=""" & CkartrisBLL.WebShopURL & "MultiMedia.aspx"" />" & vbCrLf
            litIframeMedia.Text &= "<iframe id=""media_iframe"" frameBorder=""0""" & vbCrLf
            litIframeMedia.Text &= " src=""" & CkartrisBLL.WebShopURL & "MultiMedia.aspx""" & vbCrLf
            litIframeMedia.Text &= " width=""100%""" & vbCrLf
            litIframeMedia.Text &= " height=""100%""" & vbCrLf
            litIframeMedia.Text &= " class=""iframe""" & vbCrLf
            litIframeMedia.Text &= "></iframe>" & vbCrLf

            mvwDisplay.SetActiveView(viwMedia)
            litMessage.Text = _MediaPath
        End If
        litTitle.Text = _Title
        updPopup.Update()
    End Sub

    'Can trigger from server side, but best to use
    'the PreLoadPopup
    Public Sub ShowPopup(Optional ByVal pPnl As Panel = Nothing)
        PreLoadPopup(pPnl)
        popMessage.Show()
    End Sub


    Public Sub SetWidthHeight(ByVal pWidth As Integer, ByVal pHeight As Integer)
        pnlMessage.Width = New Unit(pWidth, UnitType.Pixel)
        pnlMessage.Height = New Unit(pHeight, UnitType.Pixel)
    End Sub
End Class
