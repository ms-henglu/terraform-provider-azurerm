
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-tsi-240119025203415043"
  location = "West Europe"
}
resource "azurerm_iot_time_series_insights_standard_environment" "test" {
  name                = "accTEst_tsie240119025203415043"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "S1_1"
  data_retention_time = "P30D"
}

resource "azurerm_iot_time_series_insights_reference_data_set" "test" {
  name                                = "accTEsttsd240119025203415043"
  time_series_insights_environment_id = azurerm_iot_time_series_insights_standard_environment.test.id
  location                            = azurerm_resource_group.test.location

  key_property {
    name = "keyProperty1"
    type = "String"
  }
}
