'========================================================================
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
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

Imports Kartris
Imports System.Data

<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class kartrisServices
    Inherits System.Web.Services.WebService

    <WebMethod(EnableSession:=True)>
    <Script.Services.ScriptMethod()>
    Public Function GetTopLevelCategories(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim tblCategories As New DataTable
        tblCategories = CategoriesBLL._SearchTopLevelCategoryByName(prefixText, Session("_LANG"))

        Dim items() As String = New String() {""}
        Dim counter As Integer = 0
        For Each row As DataRow In tblCategories.Rows
            ReDim Preserve items(counter)
            items(counter) = row("CAT_Name") + vbTab + "(" + CStr(row("CAT_ID")) + ")"
            counter += 1
        Next

        Return items
    End Function

    <WebMethod(EnableSession:=True)> _
    <Script.Services.ScriptMethod()> _
    Public Function GetCategories(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim tblCategories As New DataTable
        tblCategories = CategoriesBLL._SearchCategoryByName(prefixText, Session("_LANG"))

        Dim items() As String = New String() {""}
        Dim counter As Integer = 0
        For Each row As DataRow In tblCategories.Rows
            ReDim Preserve items(counter)
            items(counter) = row("CAT_Name") + vbTab + "(" + CStr(row("CAT_ID")) + ")"
            counter += 1
        Next

        Return items
    End Function

    <WebMethod(EnableSession:=True)>
    <Script.Services.ScriptMethod()>
    Public Function GetProducts(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim tblProducts As New DataTable
        tblProducts = ProductsBLL._SearchProductByName(prefixText, Session("_LANG"))

        Dim items() As String = New String() {""}
        Dim counter As Integer = 0
        Try
            For Each row As DataRow In tblProducts.Rows
                ReDim Preserve items(counter)
                items(counter) = row("P_Name") + vbTab + "(" + CStr(row("P_ID")) + ")"
                counter += 1
            Next

        Catch ex As Exception
            'just don't do anything
        End Try
        Return items
    End Function

    <WebMethod()> _
    <Script.Services.ScriptMethod()> _
    Public Function GetVersions(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim tblVersions As New DataTable
        tblVersions = VersionsBLL._SearchVersionByCode(prefixText)

        Dim items() As String = New String() {""}
        Dim counter As Integer = 0
        For Each row As DataRow In tblVersions.Rows
            ReDim Preserve items(counter)
            items(counter) = row("V_CodeNumber") + vbTab + "(" + CStr(row("V_ID")) + ")"
            counter += 1
        Next

        Return items
    End Function


    <WebMethod()>
    <Script.Services.ScriptMethod()>
    Public Function GetVersionsExcludeBaseCombinations(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim tblVersions As New DataTable
        tblVersions = VersionsBLL._SearchVersionByCodeExcludeBaseCombinations(prefixText)

        Dim items() As String = New String() {""}
        Dim counter As Integer = 0
        For Each row As DataRow In tblVersions.Rows
            ReDim Preserve items(counter)
            items(counter) = row("V_CodeNumber") + vbTab + "(" + CStr(row("V_ID")) + ")"
            counter += 1
        Next

        Return items
    End Function



End Class
