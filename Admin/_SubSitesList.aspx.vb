'========================================================================
'Kartris - www.kartris.com
'Copyright 2023 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_SubSitesList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = "SubSites" & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")

        'Dim CallMode As OrdersBLL.ORDERS_LIST_CALLMODE
        'If Not Page.IsPostBack Then
        '    If Trim(Request.QueryString("CallMode")) <> "" Then
        '        Try
        '            'Read the query string and see if it's one of the Order list's Callmode
        '            Dim strCallMode As String = Request.QueryString("CallMode")

        '            CallMode = System.Enum.Parse(GetType(OrdersBLL.ORDERS_LIST_CALLMODE), UCase(strCallMode))

        '        Catch ex As Exception
        '            'Display in recent mode if the Querystring is invalid
        '            CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.RECENT
        '        End Try
        '    Else
        '        CallMode = OrdersBLL.ORDERS_LIST_CALLMODE.RECENT
        '    End If
        'End If

    End Sub

End Class
