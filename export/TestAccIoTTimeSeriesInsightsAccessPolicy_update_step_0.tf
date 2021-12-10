
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-211210024709724309"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie211210024709724309"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}
resource "azurerm_iot_time_series_insights_access_policy" "test" {
  name                                = "accTEst_tsiap211210024709724309"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id

  principal_object_id = "aGUID"
  roles               = ["Reader"]
}
