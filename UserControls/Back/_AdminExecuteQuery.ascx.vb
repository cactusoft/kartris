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
Partial Class UserControls_Back_AdminExecuteQuery
    Inherits System.Web.UI.UserControl

    Protected Sub btnExecuteQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExecuteQuery.Click
        ExecuteQuery()
    End Sub

    Sub ExecuteQuery()
        Dim numAffectedRecords As Integer = 0, strMessage As String = ""
        Dim tblReturnedRecords As New DataTable
        If KartrisDBBLL._ExecuteQuery(txtSqlQuery.Text, numAffectedRecords, tblReturnedRecords, Session("_User"), strMessage) Then

            If txtSqlQuery.Text.ToUpper.StartsWith("SELECT") OrElse txtSqlQuery.Text.ToUpper.StartsWith("INSERT") _
            OrElse txtSqlQuery.Text.ToUpper.StartsWith("UPDATE") OrElse txtSqlQuery.Text.ToUpper.StartsWith("DELETE") Then
                litRecordsReturned.Text = tblReturnedRecords.Rows.Count
                litRecordsAffected.Text = numAffectedRecords
                If tblReturnedRecords.Rows.Count > 0 Then
                    gvwReturnedRecords.DataSource = tblReturnedRecords
                    gvwReturnedRecords.DataBind()
                    mvwResult.SetActiveView(viwResultData)
                ElseIf tblReturnedRecords.Rows.Count = 0 Then
                    mvwResult.SetActiveView(viwNoResults)
                End If
                mvwQueryType.SetActiveView(viwNonProcedure)
            ElseIf txtSqlQuery.Text.ToUpper.StartsWith("ALTER PROCEDURE") OrElse txtSqlQuery.Text.ToUpper.StartsWith("CREATE PROCEDURE") Then
                mvwQueryType.SetActiveView(viwProcedure)
            End If
            litQueryExecutedSucceeded.Text = txtSqlQuery.Text
            mvwQuery.SetActiveView(viwQuerySucceeded)
        Else
            litQueryFailedError.Text = strMessage
            litQueryExecutedFailed.Text = txtSqlQuery.Text
            mvwQuery.SetActiveView(viwQueryFailed)
        End If
    End Sub

    Protected Sub lnkBtnBackFailed_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBackFailed.Click
        BackToQueryExecution()
    End Sub

    Protected Sub lnkBtnBackSucceeded_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lnkBtnBackSucceeded.Click
        BackToQueryExecution()
    End Sub

    Sub BackToQueryExecution()
        litRecordsAffected.Text = String.Empty
        litRecordsReturned.Text = String.Empty
        litQueryExecutedSucceeded.Text = String.Empty
        gvwReturnedRecords.DataSource = Nothing
        gvwReturnedRecords.DataBind()
        mvwQuery.SetActiveView(viwExecuteQuery)
    End Sub
End Class
