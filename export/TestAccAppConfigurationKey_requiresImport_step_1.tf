

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-210928055125109288"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf210928055125109288"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_app_configuration_key" "test" {
  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "acctest-ackey-210928055125109288"
  content_type           = "test"
  label                  = "acctest-ackeylabel-210928055125109288"
  value                  = "a test"
}


resource "azurerm_app_configuration_key" "import" {
  configuration_store_id = azurerm_app_configuration_key.test.configuration_store_id
  key                    = azurerm_app_configuration_key.test.key
  content_type           = azurerm_app_configuration_key.test.content_type
  label                  = azurerm_app_configuration_key.test.label
  value                  = azurerm_app_configuration_key.test.value
}
