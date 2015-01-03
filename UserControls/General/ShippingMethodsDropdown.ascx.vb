'========================================================================
'Kartris - www.kartris.com
'Copyright 2015 CACTUSOFT

'GNU GENERAL PUBLIC LICENSE v2
'This program is free software distributed under the GPL without any
'warranty.
'www.gnu.org/licenses/gpl-2.0.html

'KARTRIS COMMERCIAL LICENSE
'If a valid license.config issued by Cactusoft is present, the KCL
'overrides the GPL v2.
'www.kartris.com/t-Kartris-Commercial-License.aspx
'========================================================================
Imports System.Collections.Generic
Imports KartSettingsManager
Imports KartrisClasses

Partial Class UserControls_ShippingMethodsDropdown
    Inherits System.Web.UI.UserControl
    Private _boundary As Double
    Private _destinationid As Integer
    Private _shippingdetails As Kartris.Interfaces.objShippingDetails

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            If Not Me.IsPostBack Then
                If DirectCast(Page, PageBaseClass).CurrentLoggedUser Is Nothing Then
                    'Try to get new page to clear memory of previous shipping selection
                    ViewState("PreviouslySelected") = Nothing
                    Session("_selectedShippingAmount") = 0
                    Session("_selectedShippingID") = 0
                End If
            End If

            If Session("_selectedShippingAmount") = 0 And Session("_selectedShippingID") = 0 Then
                If ddlShippingMethods.Items.Count = 0 Then
                    ddlShippingMethods.Visible = False
                    litContentTextShippingAvailableAfterAddress.Visible = True
                End If
            End If
        Catch ex As Exception
            'error
            Me.Visible = False
        End Try

    End Sub

    Public Sub Refresh()
        Dim CUR_ID As Integer = CInt(Session("CUR_ID"))
        Dim lstShippingMethods As List(Of ShippingMethod) = ShippingMethod.GetAll(_shippingdetails, _destinationid, CurrenciesBLL.ConvertCurrency(CurrenciesBLL.GetDefaultCurrency, _boundary, CUR_ID))
        ddlShippingMethods.Items.Clear()
        With ddlShippingMethods
            .DataSource = lstShippingMethods
            .DataTextField = "DropDownText"
            .DataValueField = "DropDownValue"
            .DataBind()
        End With

        Dim liShippingMethod As ListItem
        Dim objCurrency As New CurrenciesBLL

        For Each liShippingMethod In ddlShippingMethods.Items
            Dim arrText As String() = Split(liShippingMethod.Text, ":")

            Dim strIncTax As String = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, CurrenciesBLL.ConvertCurrency(CUR_ID, CDbl(arrText(2))))
            Dim strExTax As String = CurrenciesBLL.FormatCurrencyPrice(CUR_ID, CurrenciesBLL.ConvertCurrency(CUR_ID, CDbl(arrText(1))))

            If GetKartConfig("frontend.display.showtax") <> "y" Then
                If GetKartConfig("general.tax.pricesinctax") <> "y" Then
                    'Show extax
                    liShippingMethod.Text = arrText(0) & vbTab.ToString & " - " & GetGlobalResourceObject("Kartris", "ContentText_Price").ToString & ": " & strExTax & _
                        vbTab.ToString()
                Else
                    'Show inctax
                    liShippingMethod.Text = arrText(0) & vbTab.ToString & " - " & GetGlobalResourceObject("Kartris", "ContentText_Price").ToString & ": " & strIncTax & _
                        vbTab.ToString()
                End If
            Else
                liShippingMethod.Text = arrText(0) & vbTab.ToString & " - " & GetGlobalResourceObject("Kartris", "ContentText_ExTax").ToString & ": " & strExTax & _
                vbTab.ToString & " / " & GetGlobalResourceObject("Kartris", "ContentText_IncTax").ToString & ": " & strIncTax
            End If

        Next

        ViewState("PreviouslySelected") = Nothing

        'customer pickup is effectively another option
        'so we must add it to find total number of shipping
        'methods - basically set to 1 or zero then add to
        'shipping methods count below
        Dim numPickUp As Integer = 0
        If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then numPickUp = 1

        If lstShippingMethods IsNot Nothing Then
            'Determine menu based on number of shipping options
            '(from shipping system) plus the pickup option which
            'is set in config setting
            If lstShippingMethods.Count < 1 And numPickUp = 1 Then
                'Customer pickup is only shipping option
                ddlShippingMethods.Visible = True
                litContentTextShippingAvailableAfterAddress.Visible = False
                If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then
                    ddlShippingMethods.Items.Insert(0, New ListItem(GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup"), "999"))
                End If
                ddlShippingMethods.SelectedIndex = 0

                Dim arrSM As String() = Split(ddlShippingMethods.SelectedValue, ":")
                Session("_selectedShippingID") = CInt(999)
                Session("_selectedShippingAmount") = CDbl(0)
                ViewState("PreviouslySelected") = 999 & "::" & GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")
                Dim lstSelected As ListItem = ddlShippingMethods.SelectedItem
                lstSelected.Text = GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")
                RaiseEvent ShippingSelected(Nothing, Nothing)

            ElseIf lstShippingMethods.Count + numPickUp > 1 Then

                'More than one option including ship options and customer pickup
                ddlShippingMethods.Visible = True
                litContentTextShippingAvailableAfterAddress.Visible = False
                If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then
                    ddlShippingMethods.Items.Insert(0, New ListItem(GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup"), "999"))
                End If
                ddlShippingMethods.Items.Insert(0, New ListItem(GetGlobalResourceObject("Kartris", "ContentText_DropdownSelectDefault"), ""))
                Session("_selectedShippingID") = 0
                Session("_selectedShippingAmount") = 0

            ElseIf lstShippingMethods.Count = 1 Then
                'One shipping option other than customer pickup
                ddlShippingMethods.Visible = True
                litContentTextShippingAvailableAfterAddress.Visible = False
                If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then
                    ddlShippingMethods.Items.Insert(0, New ListItem(GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup"), "999"))
                End If
                ddlShippingMethods.SelectedIndex = 0

                Dim arrSM As String() = Split(ddlShippingMethods.SelectedValue, ":")
                Session("_selectedShippingID") = CInt(arrSM(0))
                Session("_selectedShippingAmount") = CDbl(arrSM(1))
                ViewState("PreviouslySelected") = ddlShippingMethods.SelectedItem.Value & "::" & ddlShippingMethods.SelectedItem.Text
                Dim lstSelected As ListItem = ddlShippingMethods.SelectedItem
                lstSelected.Text = CStr(arrSM(2))
                RaiseEvent ShippingSelected(Nothing, Nothing)


            Else
                If ddlShippingMethods.Items.Count = 0 Then
                    ddlShippingMethods.Visible = False
                    litContentTextShippingAvailableAfterAddress.Visible = True
                    litContentTextShippingAvailableAfterAddress.Text = GetGlobalResourceObject("Shipping", "ContentText_NoValidShipping")
                End If

            End If
        Else
            If numPickUp = 1 Then
                'Customer pickup is only shipping option
                ddlShippingMethods.Visible = True
                litContentTextShippingAvailableAfterAddress.Visible = False
                If GetKartConfig("frontend.checkout.shipping.pickupoption") = "y" Then
                    ddlShippingMethods.Items.Insert(0, New ListItem(GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup"), "999"))
                End If
                ddlShippingMethods.SelectedIndex = 0

                Dim arrSM As String() = Split(ddlShippingMethods.SelectedValue, ":")
                Session("_selectedShippingID") = CInt(999)
                Session("_selectedShippingAmount") = CDbl(0)
                ViewState("PreviouslySelected") = 999 & "::" & GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")
                Dim lstSelected As ListItem = ddlShippingMethods.SelectedItem
                lstSelected.Text = GetGlobalResourceObject("Shipping", "ContentText_ShippingPickup")
                RaiseEvent ShippingSelected(Nothing, Nothing)
            Else
                litContentTextShippingAvailableAfterAddress.Visible = True
                litContentTextShippingAvailableAfterAddress.Text = GetGlobalResourceObject("Shipping", "ContentText_NoValidShipping")
            End If
        End If
    End Sub

    Public Property DestinationID() As Integer
        Get
            Return _destinationid
        End Get
        Set(ByVal value As Integer)
            _destinationid = value
        End Set
    End Property

    Public WriteOnly Property Boundary() As Double
        Set(ByVal value As Double)
            _boundary = value
        End Set
    End Property

    Public WriteOnly Property ShippingDetails() As Interfaces.objShippingDetails
        Set(ByVal value As Interfaces.objShippingDetails)
            _shippingdetails = value
        End Set
    End Property

    Public ReadOnly Property SelectedShippingAmount() As Double
        Get
            Return Session("_selectedShippingAmount")
        End Get
    End Property

    Public ReadOnly Property SelectedShippingID() As Integer
        Get
            Return Session("_selectedShippingID")
        End Get
    End Property

    Protected Sub ddlShippingMethods_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlShippingMethods.SelectedIndexChanged

        Dim arrSM As String() = Split(ddlShippingMethods.SelectedValue, ":")
        If UBound(arrSM) = 2 Or ddlShippingMethods.SelectedValue = "999" Then
            If UBound(arrSM) = 2 Then
                Session("_selectedShippingID") = CInt(arrSM(0))
                Session("_selectedShippingAmount") = CDbl(arrSM(1))
            Else
                Session("_selectedShippingID") = 999
                Session("_selectedShippingAmount") = 0
            End If

            If ViewState("PreviouslySelected") IsNot Nothing Then
                Dim arrPrevious As String() = Split(ViewState("PreviouslySelected"), "::")
                Dim lstPreviouslySelected As ListItem = ddlShippingMethods.Items.FindByValue(arrPrevious(0))
                lstPreviouslySelected.Text = arrPrevious(1)
            End If

            ViewState("PreviouslySelected") = ddlShippingMethods.SelectedItem.Value & "::" & ddlShippingMethods.SelectedItem.Text

            If ddlShippingMethods.SelectedValue <> "999" Then
                Dim lstSelected As ListItem = ddlShippingMethods.SelectedItem
                lstSelected.Text = CStr(arrSM(2))
            End If

            'remove the ==SELECT== item in the shipping methods dropdown after a selection
            If ddlShippingMethods.Items(0).Value = "" Then ddlShippingMethods.Items.RemoveAt(0)

            RaiseEvent ShippingSelected(sender, e)

        End If
    End Sub

    Public Event ShippingSelected(ByVal sender As Object, ByVal e As System.EventArgs)

End Class
