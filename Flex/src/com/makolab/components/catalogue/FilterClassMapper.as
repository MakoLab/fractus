package com.makolab.components.catalogue
{
	import com.makolab.components.inputComponents.AreaFilter;
	import com.makolab.components.inputComponents.ContractorFilter;
	import com.makolab.components.inputComponents.ContractorTypeFilter;
	import com.makolab.components.inputComponents.CurrentItemPriceFilter;
	import com.makolab.components.inputComponents.CurrentWarehouseFilter;
	import com.makolab.components.inputComponents.DateFilter;
	import com.makolab.components.inputComponents.EventDateFilter;
	import com.makolab.components.inputComponents.ItemsTypeFilter;
	import com.makolab.components.inputComponents.DeliveryNumberFilter;
	import com.makolab.components.inputComponents.DeliveryStatusFilter;
	import com.makolab.components.inputComponents.DocAttributesFilter;
	import com.makolab.components.inputComponents.DocCompanyFilter;
	import com.makolab.components.inputComponents.DocNumSettingsFilter;
	import com.makolab.components.inputComponents.DocNumberFilter;
	import com.makolab.components.inputComponents.DocPaymentFilter;
	import com.makolab.components.inputComponents.DocRegisterFilter;
	import com.makolab.components.inputComponents.DocRelationsFilter;
	import com.makolab.components.inputComponents.DocStatusFilter;
	import com.makolab.components.inputComponents.DocTypeFilter;
	import com.makolab.components.inputComponents.DocUnsettledFilter;
	import com.makolab.components.inputComponents.DocWarehouseFilter;
	import com.makolab.components.inputComponents.FiskalDocumentFilter;
	import com.makolab.components.inputComponents.FlagsFilter;
	import com.makolab.components.inputComponents.GenericDocumentAttributeFilter;
	import com.makolab.components.inputComponents.ItemAvailabilityFilter;
	import com.makolab.components.inputComponents.ItemInInventoryFilter;
	import com.makolab.components.inputComponents.LocationFilter;
	import com.makolab.components.inputComponents.ObjectTypeFilter;
	import com.makolab.components.inputComponents.PriceFilter;
	import com.makolab.fractus.view.catalogue.ItemAttributeFilter;
	import com.makolab.fractus.view.catalogue.DocumentAttributeFilter;
	
	public class FilterClassMapper
	{
		public function FilterClassMapper()
		{
		}
		public static const CLASSES:Object = {
												contractorTypeFilter : ContractorTypeFilter,
												currentWarehouseFilter : CurrentWarehouseFilter,
												currentItemPriceFilter : CurrentItemPriceFilter,
												dateFilter : DateFilter,
												eventDateFilter : EventDateFilter,
												docStatusFilter : DocStatusFilter,
												docNumberFilter : DocNumberFilter,
												docTypeFilter : DocTypeFilter,
												docCompanyFilter : DocCompanyFilter,
												docWarehouseFilter : DocWarehouseFilter,
												docNumSettingsFilter : DocNumSettingsFilter,
												docRelationsFilter : DocRelationsFilter,
												docUnsettledFilter : DocUnsettledFilter,
												docPaymentFilter : DocPaymentFilter,
												sqlFilter : SqlFilter,
												docRegisterFilter : DocRegisterFilter,
												itemAttributeFilter : ItemAttributeFilter,
												itemTypeFilter : ItemsTypeFilter,
												itemAvailabilityFilter : ItemAvailabilityFilter,
												itemInInventoryFilter : ItemInInventoryFilter,
												docAttributeFilter : GenericDocumentAttributeFilter,
												documentAttributeFilter : DocumentAttributeFilter,
												docAttributesFilter : DocAttributesFilter,
												fiscalDocumentFilter : FiskalDocumentFilter,
												objectTypeFilter : ObjectTypeFilter,
												locationFilter : LocationFilter,
												priceFilter : PriceFilter,
												areaFilter : AreaFilter,
												flagsFilter : FlagsFilter,
												deliveryStatusFilter : DeliveryStatusFilter,
												deliveryNumberFilter : DeliveryNumberFilter,
												contractorFilter:ContractorFilter
											 };

	}
}