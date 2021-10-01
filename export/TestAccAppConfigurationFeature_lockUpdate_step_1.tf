
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211001020448655446"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211001020448655446"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_feature" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  description            = "test description"
  name                   = "acctest-ackey-211001020448655446"
  label                  = "acctest-ackeylabel-211001020448655446"
  enabled                = true
  locked                 = true
}
