
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-230106034606440220"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie230106034606440220"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}
resource "azurerm_iot_time_series_insights_access_policy" "test" {
  name                                = "accTEst_tsiap230106034606440220"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id

  principal_object_id = "aGUID"
  roles               = ["Reader"]
}
