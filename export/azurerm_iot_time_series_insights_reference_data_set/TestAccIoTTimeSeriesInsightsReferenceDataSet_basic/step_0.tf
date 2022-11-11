
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-221111020628555157"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie221111020628555157"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}

resource "azurerm_iot_time_series_insights_reference_data_set" "test" {
  name                                = "accTEsttsd221111020628555157"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id
  location                            = azurerm_resource_group.test.location

  key_property {
    name = "keyProperty1"
    type = "String"
  }
}
