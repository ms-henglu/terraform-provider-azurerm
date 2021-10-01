

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211001053427191878"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211001053427191878"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211001053427191878"
  content_type           = "test"
  label                  = "acctest-ackeylabel-211001053427191878"
  value                  = "a test"
}


resource "azurerm_app_configuration_key" "import" {
  configuration_store_id = azurerm_app_configuration_key.test.configuration_store_id
  key                    = azurerm_app_configuration_key.test.key
  content_type           = azurerm_app_configuration_key.test.content_type
  label                  = azurerm_app_configuration_key.test.label
  value                  = azurerm_app_configuration_key.test.value
}
