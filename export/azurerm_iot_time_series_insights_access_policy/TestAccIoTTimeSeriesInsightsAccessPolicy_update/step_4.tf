
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-230825024710958416"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie230825024710958416"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}
resource "azurerm_iot_time_series_insights_access_policy" "test" {
  name                                = "accTEst_tsiap230825024710958416"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id

  principal_object_id = "aGUID"
  roles               = ["Reader"]
}
