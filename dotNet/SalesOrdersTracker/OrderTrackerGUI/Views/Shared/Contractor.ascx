<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<TrackerDataAccessLayer.Contractor>" %>
	<%  if (Model.ContractorType == TrackerDataAccessLayer.Enums.ContractorType.Company) { %>
    <div id="accordion_client">
        <h3><a href="#">Dane Klienta</a></h3>
        <div class="dlDiv">
            <table cellspacing="0" cellpadding="0" border="0" class="dateTable">
			    <tbody>
		          	<tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.FullName)%>:</td>
	                    <td class="dd"><%= Model.FullName%></td>
	                </tr>
                    <tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.Address)%>:</td>
	                    <td class="dd"><%= Model.Address%></td>
	                </tr>      
                    <tr>
		            	<td class="dt"><%= Html.LabelFor(model => model.City)%>:</td>
	                    <td class="dd"><%= Model.City%></td>
	                </tr>      
				</tbody>
            </table> 
        </div>
    </div> 
	<% } %>
