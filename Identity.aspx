<%@ Page Language="VB" %>

<!DOCTYPE html>

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
             Current user: <%= System.Security.Principal.WindowsIdentity.GetCurrent().Name %>
    </div>
    </form>
</body>
</html>
