<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<OrderList>" %>

<%@ Import Namespace="OrderTrackerGUI.Models" %>

<asp:Content ID="PageTitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Lista zamówień
</asp:Content>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <script type="text/javascript">
        jQuery(document).ready(function ($) {
            $("#accordion_items").accordion({
                collapsible: true
            });
            $("#accordion_client").accordion({
                collapsible: true,
                active: false
            });
        });
	</script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>
        Lista zamówień
    </h2>

	<% Html.RenderPartial("Contractor", Model.Contractor); %>

    <div id="accordion_items">
        <h3><a href="#">Aktualne zamówienia</a></h3>
        <div>
            <table cellspacing="0" cellpadding="0" border="0" class="dataTable">
			    <tbody>
                    <tr>
	        		    <th>Zamówienie</th>
	        		    <th>Data zamówienia</th>
                        <th>Status</th>	
                        <th>Szczegóły</th>
	        	    </tr>

                    <%  int orderCounter = 0;
                        foreach(var order in Model.Orders) {       
                    %>
                        <tr <% if(orderCounter % 2 == 0){ %>class="odd"<% } %>>
		            	    <td ><%: order.Number %></td>
	                        <td ><%: order.RegistrationDate.ToShortDateString() %></td>
	                        <td ><%: order.DisplayStatus %></td>
                            <td><%: Html.ActionLink("Szczegóły", "Order", "Home", new { id = order.Id }, null)%></td>
	                    </tr>  
                    <%  orderCounter++;
                        }%>

				</tbody>
            </table>
        </div>
    </div>

</asp:Content>
