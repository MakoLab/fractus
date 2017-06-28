<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<TrackerDataAccessLayer.Item>" %>
<%	if (Model.reserved.HasValue) %>
<%	{ %>
<%		if (Model.reserved.Value == 1) %>
<%		{ %>
			<img alt="W magazynie" src="<%= Url.Content("~/Content/Images/checked.gif") %>" />
<%		} %>
<%		else %>
<%		{  %>
			<img alt="Brak w magazynie" src="<%= Url.Content("~/Content/Images/unchecked.gif") %>" />
<%		} %>
<%	} %>
<%	else %>
<%	{ %>
			&nbsp;
<%	} %>

