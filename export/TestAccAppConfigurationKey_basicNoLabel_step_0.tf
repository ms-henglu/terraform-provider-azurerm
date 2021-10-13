
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211013071507551364"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211013071507551364"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211013071507551364"
  content_type           = "test"
  value                  = "a test"
}
