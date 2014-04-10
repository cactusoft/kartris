'========================================================================
'Kartris - www.kartris.com
'Copyright 2014 CACTUSOFT INTERNATIONAL FZ LLC

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Xml

Partial Class SiteMap
    Inherits PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'New usercontrol
        Dim objCategoryMenuUserControl As Control
        objCategoryMenuUserControl = LoadControl("~/UserControls/Skin/CategoryMenuAccordion.ascx")

        'Add appropriate menu control
        phdCategoryMenu.Controls.Add(objCategoryMenuUserControl)
    End Sub

End Class
