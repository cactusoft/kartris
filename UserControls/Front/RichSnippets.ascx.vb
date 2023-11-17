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
Imports CkartrisDataManipulation

Partial Class UserControls_Front_RichSnippets
    Inherits System.Web.UI.UserControl

    Private _ProductID As Integer
    Public WriteOnly Property ProductID() As Integer
        Set(value As Integer)
            _ProductID = value
        End Set
    End Property

    Protected Sub UserControls_Front_RichSnippets_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack AndAlso _ProductID > 0 Then
            LoadSnippets()
        End If
    End Sub

    Sub LoadSnippets()

        Try

            Dim objVersionsBLL As New VersionsBLL
            Dim dtbVersions As DataTable = objVersionsBLL.GetRichSnippetsPropertiesMulti(_ProductID, Session("LANG"))

            Dim strURL As String = CkartrisBLL.WebShopURL.ToLower & "======" & SiteMapHelper.CreateURL(SiteMapHelper.Page.CanonicalProduct, _ProductID) ' added the === bit to make it easier to remove the double slash from joining webshopURL with the page URL local
            strURL = Replace(strURL, "/======/", "/")

            ' Create a StringBuilder to build the JSON-LD snippet
            Dim sb As New StringBuilder()

            sb.Append("<script type=""application/ld+json"">")
            sb.Append("[") ' Start an array of products

            '' Image
            Dim strImageLink As String = ""
            Dim dirFolder As New DirectoryInfo(Server.MapPath(CkartrisImages.strProductImagesPath & "/" & _ProductID & "/"))
            If dirFolder.Exists Then
                If dirFolder.GetFiles().Length > 0 Then
                    For Each objFile In dirFolder.GetFiles()
                        strImageLink = Replace(CkartrisImages.strProductImagesPath, "~/", CkartrisBLL.WebShopURL()) & "/" & _ProductID & "/" & objFile.Name
                        'strImageLink = strImageLink.Replace("/", "\/") 'JSON escape forward slash,  not required
                        Exit For
                    Next
                End If
            End If

            Dim blnFirstProduct As Boolean = True ' Initialize a flag for the first product


            For Each dr In dtbVersions.Rows
                '------ LOOP THROUGH VERSIONS -----------

                If dr("V_Price") <> 0 Then

                    sb.AppendLine(If(blnFirstProduct, "{", ",{")) ' Add a comma before the product JSON section if it's not the first product
                    sb.AppendLine("""@context"": ""http://schema.org"",")
                    sb.AppendLine("""@type"": ""Product"",")
                    sb.AppendLine("""name"": """ + Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("V_Name"))), """", "\""") + """,")
                    sb.AppendLine("""description"": """ + Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("P_Desc"))), """", "\""") + """,")
                    sb.AppendLine("""mpn"": """ + Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("V_CodeNumber"))), """", "\""") + """,")
                    sb.AppendLine("""sku"": """ + Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("V_CodeNumber"))), """", "\""") + """,")
                    sb.AppendLine("""image"": [""" + strImageLink + """],")
                    sb.AppendLine("""brand"": {")
                    sb.AppendLine("  ""@type"": ""Brand"",")
                    sb.AppendLine("  ""name"": """ + Replace(CkartrisDisplayFunctions.StripHTML(FixNullFromDB(dr("SUP_Name"))), """", "\""") + """")
                    sb.AppendLine("  },")
                    sb.AppendLine("""offers"": {")
                    sb.AppendLine("  ""@type"": ""Offer"",")
                    sb.AppendLine("  ""url"": """ + strURL + """,")
                    sb.AppendLine("  ""price"": """ + CurrenciesBLL.FormatCurrencyPrice(Session("CUR_ID"), FixNullFromDB(dr("V_Price")), False) + """,")
                    sb.AppendLine("  ""priceCurrency"": """ + FixNullFromDB(dr("CUR_ISOCode")) + """,")

                    'Availability
                    If dr("V_QuantityWarnLevel") = 0 Then
                        sb.AppendLine("  ""availability"": ""http://schema.org/InStock""")
                    Else
                        'Allowpurchaseoutstock?
                        If LCase(KartSettingsManager.GetKartConfig("frontend.orders.allowpurchaseoutofstock")) = "y" Then
                            If dr("V_Quantity") < 1 Then
                                sb.AppendLine("  ""availability"": ""http://schema.org/BackOrder""")
                            Else
                                sb.AppendLine("  ""availability"": ""http://schema.org/InStock""")
                            End If
                        Else
                            If dr("V_Quantity") < 1 Then
                                sb.AppendLine("  ""availability"": ""http://schema.org/OutOfStock""")
                            Else
                                sb.AppendLine("  ""availability"": ""http://schema.org/InStock""")
                            End If
                        End If
                    End If

                    sb.AppendLine("  }")
                    sb.AppendLine("}")
                    blnFirstProduct = False

                End If

                '------ / END OF LOOP -----------
            Next

            sb.AppendLine("]") ' Start an array of products
            sb.AppendLine("</script>")

            litJSONLD.Text = sb.ToString()


        Catch ex As Exception

        End Try


    End Sub
End Class

