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
Imports System.Data
Imports CkartrisDataManipulation
Imports CkartrisDisplayFunctions


Partial Class UserControls_Back_EditCouponPopup
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' raised when the user click "yes" to confirm the operation
    ''' </summary>
    ''' <remarks></remarks>
    Public Event CouponSaved()
    Public Event CouponErrorOnSave()

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '' The following line is important for the confirmation msg box
        ''  => it will allow the event of the server side button to be fired
        Page.ClientScript.GetPostBackEventReference(Me, String.Empty)
    End Sub

    ''' <summary>
    ''' sets the text that will be shown in the confirmation box
    ''' </summary>
    ''' <value></value>
    ''' <remarks></remarks>
    Public WriteOnly Property SetTitle() As String
        Set(ByVal value As String)
            If value <> "" Then litTitle.Text = value
        End Set
    End Property

    Public Sub LoadCouponInfo(ByVal numCouponID As Short)
        Dim rowCoupon As DataRow = CouponsBLL._GetCouponByID(numCouponID)

        If rowCoupon Is Nothing Then
            phdContents.Visible = False
            litMessage.Visible = True
            popExtender.Show()
            Return
        End If
        litErrorMessage.Text = String.Empty

        ddlDiscountType.Items.Clear()
        ddlDiscountType.Items.Add(New ListItem("%", "p"))
        ddlDiscountType.Items.Add(New ListItem(CurrenciesBLL.CurrencyCode(CurrenciesBLL.GetDefaultCurrency()), "f"))
        ddlDiscountType.Items.Add(New ListItem(GetGlobalResourceObject("_Coupons", "ContentText_Promotion"), "t"))

        '' Support for the promotions in coupons
        Dim tblPromotions As New DataTable
        tblPromotions.Columns.Add(New DataColumn("PROM_ID", Type.GetType("System.Int32")))
        tblPromotions.Columns.Add(New DataColumn("PROM_Name", Type.GetType("System.String")))

        Dim drPromotions As DataRow() = PromotionsBLL._GetData().Select("PROM_Live = 0")
        For i As Integer = 0 To drPromotions.Length - 1
            tblPromotions.Rows.Add(drPromotions(i)("PROM_ID"), GetPromotionName(CStr(drPromotions(i)("PROM_ID"))))
        Next
        ddlPromotions.Items.Clear()
        ddlPromotions.Items.Add(New ListItem(GetGlobalResourceObject("_Kartris", "ContentText_DropDownSelect"), "0"))
        ddlPromotions.AppendDataBoundItems = True
        ddlPromotions.DataTextField = "PROM_Name"
        ddlPromotions.DataValueField = "PROM_ID"
        ddlPromotions.DataSource = tblPromotions
        ddlPromotions.DataBind()

        litCouponID.Text = numCouponID
        txtDiscountValue.Text = FixNullFromDB(rowCoupon("CP_DiscountValue"))
        txtCouponCode.Text = FixNullFromDB(rowCoupon("CP_CouponCode"))
        txtStartDate.Text = Format(CDate(FixNullFromDB(rowCoupon("CP_StartDate"))), "yyyy/MM/dd")
        txtEndDate.Text = Format(CDate(FixNullFromDB(rowCoupon("CP_EndDate"))), "yyyy/MM/dd")
        ddlDiscountType.SelectedValue = FixNullFromDB(rowCoupon("CP_DiscountType"))
        chkReusable.Checked = FixNullFromDB(rowCoupon("CP_Reusable"))
        chkLive.Checked = FixNullFromDB(rowCoupon("CP_Enabled"))

        If FixNullFromDB(rowCoupon("CP_DiscountType")) = "t" Then
            ddlPromotions.SelectedValue = FixNullFromDB(rowCoupon("CP_DiscountValue"))
            ddlDiscountType_SelectedIndexChanged(Nothing, Nothing)
        End If

        If FixNullFromDB(rowCoupon("CP_Used")) = True Then LockControls()

        UpdateUI()
        popExtender.Show()
    End Sub

    Protected Function GetPromotionName(numPromotionID As Integer) As String
        Return LanguageElementsBLL.GetElementValue(Session("_lang"), CkartrisEnumerations.LANG_ELEM_TABLE_TYPE.Promotions, _
                                                                   CkartrisEnumerations.LANG_ELEM_FIELD_NAME.Name, numPromotionID)
    End Function

    Sub LockControls()
        txtDiscountValue.ReadOnly = True
        txtStartDate.ReadOnly = True
        txtEndDate.ReadOnly = True
        ddlDiscountType.Enabled = False
        imgBtnStart.Enabled = False
        imgBtnEnd.Enabled = False
    End Sub

    Protected Sub lnkBtnSaveCoupon_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnSaveCoupon.Click
        If SaveChanges() Then
            RaiseEvent CouponSaved()
        Else
            RaiseEvent CouponErrorOnSave()
        End If

    End Sub

    Public Function GetErrorMessage() As String
        Return litErrorMessage.Text
    End Function

    Function SaveChanges() As Boolean

        Dim numCouponID As Short = CShort(litCouponID.Text)
        Dim chrDiscountType As Char = CChar(ddlDiscountType.SelectedValue)
        Dim sngDiscountValue As Single = 0.0F
        If chrDiscountType = "t" Then
            sngDiscountValue = ddlPromotions.SelectedValue
        Else
            sngDiscountValue = HandleDecimalValues(txtDiscountValue.Text)
        End If
        Dim datStartDate As Date = CDate(txtStartDate.Text)
        Dim datEndDate As Date = CDate(txtEndDate.Text)
        Dim blnReusable As Boolean = chkReusable.Checked
        Dim blnLive As Boolean = chkLive.Checked
        Dim strMessage As String = ""

        If Not CouponsBLL._UpdateCoupon(numCouponID, sngDiscountValue, chrDiscountType, _
                            datStartDate, datEndDate, blnReusable, blnLive, strMessage) Then
            litErrorMessage.Text = strMessage
            Return False
        End If

        Return True
    End Function

    Protected Sub ddlDiscountType_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles ddlDiscountType.SelectedIndexChanged
        UpdateUI()
        popExtender.Show()
    End Sub
    Private Sub UpdateUI()
        If ddlDiscountType.SelectedValue = "t" Then
            valRegexCouponValue.Enabled = False
            valRequiredCouponValue.Enabled = False
            phdNonPromotionType.Visible = False
            phdPromotionType.Visible = True
            valComparePromotion.Enabled = True
        Else
            valRegexCouponValue.Enabled = True
            valRequiredCouponValue.Enabled = True
            phdNonPromotionType.Visible = True
            phdPromotionType.Visible = False
            valComparePromotion.Enabled = False
        End If
    End Sub
End Class
