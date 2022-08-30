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
Partial Class UserControls_Back_OrderBreadcrumb
    Inherits System.Web.UI.UserControl
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            Dim intOrderID As Long = CType(Request.QueryString("OrderID"), Integer)
            Dim objOrdersBLL As New OrdersBLL

            Dim blnHasParent As Boolean = True
            Dim blnHasChild As Boolean = True
            Dim intParentID As Long = 0
            Dim intChildID As Long = 0
            Dim strLinks As String = "<span><a style='font-weight:bold;color:#fff' href='/Admin/_ModifyOrderStatus.aspx?OrderID=" & intOrderID.ToString & "'>#" & intOrderID.ToString & "</a></span>"

            If intOrderID > 0 Then

                'Let's look for parent orders
                Do While blnHasParent = True
                    intParentID = objOrdersBLL._GetParentOrderID(intOrderID)

                    'If no parent, let's exit
                    If intParentID = 0 Then
                        blnHasParent = False
                    Else
                        'Add parent to string
                        strLinks = "<span><a href='/Admin/_ModifyOrderStatus.aspx?OrderID=" & intParentID & "'>#" & intParentID & "</a></span> " & strLinks

                        'Set parent as current, so we can do next search for parents of that
                        intOrderID = intParentID
                    End If
                Loop

                'Reset order number back to start
                intOrderID = CType(Request.QueryString("OrderID"), Integer)

                Do While blnHasChild = True
                    intChildID = objOrdersBLL._GetChildOrderID(intOrderID)

                    'If no parent, let's exit
                    If intChildID = 0 Then
                        blnHasChild = False
                    Else
                        'Add parent to string
                        strLinks = strLinks & " <span><a href='/Admin/_ModifyOrderStatus.aspx?OrderID=" & intChildID & "'>#" & intChildID & "</a></span>"

                        'Set child as current, so we can do next search for children of that
                        intOrderID = intChildID
                    End If
                Loop

                litLinks.Text = strLinks
            Else
                Me.Visible = False
            End If
        End If
    End Sub
End Class
