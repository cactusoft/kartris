'[[[NEW COPYRIGHT NOTICE]]]
Partial Class Admin_Category
    Inherits _PageBaseClass

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Page.Title = GetGlobalResourceObject("_Category", "BackMenu_Categories") & " | " & GetGlobalResourceObject("_Kartris", "ContentText_KartrisName")
    End Sub
End Class
