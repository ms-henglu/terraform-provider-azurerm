

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211105035515849234"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf211105035515849234"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211105035515849234"
  content_type           = "test"
  label                  = "acctest-ackeylabel-211105035515849234"
  value                  = "a test"
}


resource "azurerm_app_configuration_key" "test1" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-211105035515849234"
  content_type           = "test"
  value                  = "a test"
}
