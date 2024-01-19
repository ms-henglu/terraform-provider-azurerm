
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-240119025203414760"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie240119025203414760"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"

  storage_limit_exceeded_behavior = "PauseIngress"

  tags = {
    Environment = "Production"
  }
}
