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

Partial Class LicenseService
    Inherits PageBaseClass

    Protected Sub Page_Load1(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'If DigitalSignatureHelper.GetLicenseDomain() <> "http://www.kartris.com" _
        '    OrElse KartSettingsManager.GetKartConfig("general.webshopurl") = "http://www.kartris.com/" Then
        '    mvwMain.SetActiveView(viwNotExist)
        'End If

    End Sub

    
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click
        Dim strMsg As String = Nothing, strNewLicense As String = Nothing
        Dim strDomain As String = txtDomain.Text
        txtDomain.Text = Nothing
        Dim srvc As kartlic.CactusoftServices = New kartlic.CactusoftServices()
        Dim buffer As Byte() = Nothing
        Select Case srvc.IssueTrialLicense(strDomain, 0, buffer)
            Case kartlic.LicenseService.DomainExist
                litDomainExist.Text = "<p>We are sorry, the domain <strong>" & strDomain & "</strong> is already exist in our database.</p>"
                mvwMain.SetActiveView(viwDomainExist)
                updMain.Update()
            Case kartlic.LicenseService.LicenseNotIssued
                mvwMain.SetActiveView(viwError)
                updMain.Update()
            Case kartlic.LicenseService.LicenseIssued
                Response.Clear()
                Response.AddHeader("Content-Disposition", "attachment; filename=license.config")
                Response.AddHeader("Content-Length", buffer.Length.ToString)
                Response.ContentType = "application/octet-stream"
                Response.OutputStream.Write(buffer, 0, buffer.Length - 1)
                Response.End()
            Case kartlic.LicenseService.AccessRestricted

            Case Else
        End Select

    End Sub

    Protected Sub Back_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBack1.Click, lnkBtnBack2.Click
        mvwMain.SetActiveView(viwKartrisSite)
        updMain.Update()
    End Sub
End Class
