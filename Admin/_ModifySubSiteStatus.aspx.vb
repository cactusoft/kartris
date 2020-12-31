﻿'========================================================================
'Kartris - www.kartris.com
'Copyright 2021 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Partial Class Admin_ModifySubSiteStatus
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = "SubSite Details" & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub

    Protected Sub ShowMasterUpdateMessage() Handles _UC_SubSiteDetails.ShowMasterUpdate
        CType(Me.Master, Skins_Admin_Template).DataUpdated()
        CType(Me.Master, Skins_Admin_Template).LoadTaskList()
    End Sub

End Class
