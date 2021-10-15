
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211015013848018770"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211015013848018770"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211015013848018770"
  content_type           = "test"
  label                  = "acctest-ackeylabel-211015013848018770"
  value                  = "a test"
}
