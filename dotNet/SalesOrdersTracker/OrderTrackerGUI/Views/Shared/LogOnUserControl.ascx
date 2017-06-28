<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>
<%
    var user = Session[OrderTrackerGUI.SessionKeys.CurrentUser] as OrderTrackerGUI.Models.User;
    if (user != null) {
%>
        Witaj <b><%: user.Login %></b>
        [ <%: Html.ActionLink("Wyloguj", "Logout", "Account") %> ]
<%
    }
    else {
%> 
        <%--[ <%: Html.ActionLink("Zaloguj", "Login", "Account") %> ]--%>
<%
    }
%>
