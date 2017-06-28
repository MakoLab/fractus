<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<SalesOrderSnapshot>" %>

<%@ Import Namespace="TrackerDataAccessLayer" %>
<%@ Import Namespace="TrackerDataAccessLayer.Enums" %>

<asp:Content ID="PageTitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Zamówienie
</asp:Content>
<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <script type="text/javascript">
        jQuery(document).ready(function ($) {
            $("#accordion_client").accordion({
                collapsible: true,
                active: false
            });
            $("#accordion_items").accordion({
                collapsible: true,
                active: false
            });
            $("#accordion_history").accordion({
                collapsible: true
            });
        });
	</script>
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <%--<h3 class="header_status">
        Status: <strong>Zaliczkowane</strong>
    </h3>--%>
    <h2>
        Zamówienie nr <strong><%: Model.Number %></strong>
		<br />
        <%= Html.LabelFor(model => model.DisplayStatus) %>: <strong><%= Model.DisplayStatus %></strong>
    </h2>

    <div class="dlDiv">
        <table cellspacing="0" cellpadding="0" border="0" class="dateTable">
			    <tbody>
		          	<tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.RegistrationDate)%>:</td>
	                    <td class="dd"><%= Model.RegistrationDate.ToShortDateString() %></td>
	                </tr>              
                    <tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.Value)%>:</td>
	                    <td class="dd"><%= String.Format("{0:N} PLN", Model.Value) %></td>
	                </tr>  
					<% if (Model.FittingDate.HasValue)
					{%>    
		          	<tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.FittingDate)%>:</td>
	                    <td class="dd"><%= Model.FittingDate.ToShortDate()%></td>
	                </tr>
					<% } %>
					<% if (!String.IsNullOrWhiteSpace(Model.Remarks))
					{%>    
		          	<tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.Remarks)%>:</td>
	                    <td class="dd"><%= Model.Remarks%></td>
	                </tr>
					<% } %>
				</tbody>
            </table>
    </div>

	<% Html.RenderPartial("Contractor", Model.Contractor); %>
	<% bool showReservation = Model.StatusName != SalesOrderStatusName.Cancelled && Model.StatusName != SalesOrderStatusName.Commited; %>

    <div id="accordion_items">
        <h3><a href="#">Lista towarów</a></h3>
        <div>
            <table cellspacing="0" cellpadding="0" border="0" class="dataTable">
			    <tbody>
                    <tr>
						<th>Lp.</th>
	        		    <th>&nbsp;</th>
	        		    <th class="right">Ilość</th>
                        <th class="right">Cena netto</th>
	        		    <th class="right">Wartość brutto</th>	
						<% if (showReservation) %>
						<% { %>
	        		    <th class="center">W magazynie</th>
						<% } %>	
	        	    </tr>

                    <%  int itemsCounter = 0;
                        foreach(var item in Model.Items) {       
                    %>
                        <tr <% if(itemsCounter % 2 == 0) { %>class="odd"<% } %>>
							<% itemsCounter++; %>
							<td><%: itemsCounter %></td>
		            	    <td ><%: item.itemName %></td>
	                        <td align="right"><%: String.Format("{0:F0}", item.quantity) %></td>
	                        <td align="right">&nbsp;<%: item.price.ToCurrency() %></td>
	                        <td align="right">&nbsp;<%: item.value.ToCurrency() %></td>
							<% if (showReservation) %>
							<% { %>
	                        <td align="center"><% Html.RenderPartial("NullableCheckbox", item); %></td>
							<%--Nie chce działać na prymitywnym typie nullable dlatego w końcu jest zrobiony na itemie--%>
							<% } %>	
	                    </tr>  
                    <% } %>
                   
				</tbody>
            </table>
        </div>
    </div>

    <div class="dlDiv">
        <table cellspacing="0" cellpadding="0" border="0" class="dateTable">
			    <tbody>
				</tbody>
            </table>
    </div>

    <div id="accordion_history">
        <h3><a href="#">Historia zamówienia</a></h3>
        <div>
            <table cellspacing="0" cellpadding="0" border="0" class="dataTable">
			    <tbody>    
                    <tr>
	        		    <th>Data</th>
	        		    <th>Zdarzenie</th>     
	        	    </tr>

                    <%  int orderEventCounter = 0;
                        foreach(var oEvent in Model.SalesOrderEventsList) {
                    %>
                        <tr <% if(orderEventCounter % 2 == 0){ %>class="odd"<% } %>>
		            	    <td ><%: oEvent.Date%></td>
	                        <td ><%: oEvent.Description %></td>
	                    </tr>
                    <%  orderEventCounter++;
                    }%>
				</tbody>
            </table>
        </div>
    </div>
</asp:Content>

