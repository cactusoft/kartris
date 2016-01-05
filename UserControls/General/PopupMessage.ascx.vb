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
Partial Class UserControls_General_PopupMessage
    Inherits System.Web.UI.UserControl

    Enum POPUP_TYPE
        TEXT = 1
        IMAGE = 2 'This is deprecated from v2.9, we use the Foundation Clearing lightbox now
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

            'We now use Foundation's Clearing lightbox
            'so this code is not needed from
            'Kartris v2.9 onwards

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
            litIframeMedia.Text &= "<div id=""iframe_container"" style=""margin-right:-50px;height:100%;"">" & vbCrLf
            litIframeMedia.Text &= "<iframe id=""media_iframe"" frameBorder=""0""" & vbCrLf
            litIframeMedia.Text &= " src=""" & CkartrisBLL.WebShopURL & "MultiMedia.aspx""" & vbCrLf
            litIframeMedia.Text &= " width=""100%""" & vbCrLf
            litIframeMedia.Text &= " height=""100%""" & vbCrLf
            litIframeMedia.Text &= " class=""iframe""" & vbCrLf
            litIframeMedia.Text &= "></iframe>" & vbCrLf
            litIframeMedia.Text &= "</div>" & vbCrLf

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
        'If values of 999 used, we assume 100% rather than pixel
        If pWidth = 999 And pHeight = 999 Then
            pnlMessage.Width = New Unit(100, UnitType.Percentage)
            pnlMessage.Height = New Unit(100, UnitType.Percentage)
            'If is full height and width, we want to hide
            'the border and make the close button bigger to
            'match the Foundation lightbox. We just activate
            'the DIV around the contents which lets us
            'apply an extra style to the popup
        Else
            pnlMessage.Width = New Unit(pWidth, UnitType.Pixel)
            pnlMessage.Height = New Unit(pHeight, UnitType.Pixel)
        End If
    End Sub
End Class
