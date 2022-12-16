
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-221216013651938774"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie221216013651938774"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"

  storage_limit_exceeded_behavior = "PauseIngress"

  tags = {
    Environment = "Production"
  }
}
