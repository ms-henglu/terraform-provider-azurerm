


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-210825025555536631"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-210825025555536631"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}


resource "azurerm_healthbot" "import" {
  name                = azurerm_healthbot.test.name
  resource_group_name = azurerm_healthbot.test.resource_group_name
  location            = azurerm_healthbot.test.location
  sku_name            = azurerm_healthbot.test.sku_name
}
