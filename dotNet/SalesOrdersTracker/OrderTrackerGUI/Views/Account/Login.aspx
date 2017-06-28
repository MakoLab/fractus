<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<OrderTrackerGUI.Models.User>" %>

<asp:Content ID="loginTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Logowanie
</asp:Content>

<asp:Content ID="loginHeader" ContentPlaceHolderID="HeadContent" runat="server">
	<script type="text/javascript" src="<%= Url.Content("~/Scripts/sha256.js") %>"></script>
</asp:Content>

<asp:Content ID="loginContent" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Logowanie</h2>

    <% using (Html.BeginForm()) { %>
        <div>
            <fieldset>
                <legend>Informacje o użytkowniku</legend>
                
                <div class="editor-label">
                    <%: Html.LabelFor(m => m.Login) %>
                </div>
                <div class="editor-field">
                    <%: Html.TextBoxFor(m => m.Login) %>
                    <%: Html.ValidationMessageFor(m => m.Login) %>
                </div>
                
                <div class="editor-label">
                    <%: Html.LabelFor(m => m.Password) %>
                </div>
                <div class="editor-field">
					<input id="_Password" type="password" />
                    <%: Html.ValidationMessageFor(m => m.Password) %>
                </div>
                
				<input id="Password" name="Password" type="hidden" />

                <p>
                    <input type="submit" value="Zaloguj" onclick="$('#Password').val((sha256_digest($('#_Password').val())))" />
                </p>
				<%: Html.ValidationSummary(true) %>
            </fieldset>
        </div>
    <% } %>
</asp:Content>
