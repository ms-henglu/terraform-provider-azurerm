
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211013071507552449"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211013071507552449"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211013071507552449"
  content_type           = "test"
  label                  = "acctest-ackeylabel-211013071507552449"
  value                  = "a test"
}
