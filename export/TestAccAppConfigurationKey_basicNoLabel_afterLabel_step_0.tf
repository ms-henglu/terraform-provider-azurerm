

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211015013848019346"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211015013848019346"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211015013848019346"
  content_type           = "test"
  label                  = "acctest-ackeylabel-211015013848019346"
  value                  = "a test"
}


resource "azurerm_app_configuration_key" "test1" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211015013848019346"
  content_type           = "test"
  value                  = "a test"
}
