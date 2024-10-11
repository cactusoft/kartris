'========================================================================
'Kartris - www.kartris.com
'Copyright 2024 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports CkartrisEnumerations
Imports CkartrisDataManipulation
Imports KartSettingsManager

Partial Class Admin_WholesaleApplicationsList
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = "Anonymization List" & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
        If Not Page.IsPostBack Then
            GetGuestsList()
        End If

    End Sub

    Protected Sub btnAnonymize_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAnonymize.Click
        Dim objUsersBLL As New UsersBLL
        objUsersBLL._AnonymizeAll()
        GetGuestsList()
    End Sub

    Private Sub GetGuestsList()
        gvwCustomers.DataSource = Nothing
        gvwCustomers.DataBind()
        'get wholesale - pending customer group list (U_CustomerGroupID = 1)
        Dim objUsersBLL As New UsersBLL
        gvwCustomers.DataSource = objUsersBLL._GetGuestList()
        gvwCustomers.DataBind()
    End Sub


End Class
