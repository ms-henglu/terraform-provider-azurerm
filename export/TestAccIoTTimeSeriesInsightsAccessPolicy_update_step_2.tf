
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-210924011109056685"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie210924011109056685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}
resource "azurerm_iot_time_series_insights_access_policy" "test" {
  name                                = "accTEst_tsiap210924011109056685"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id

  principal_object_id = "aGUID"
  roles               = ["Contributor"]
  description         = "Test Access Policy"
}
