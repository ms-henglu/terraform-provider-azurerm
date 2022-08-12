


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-220812014714446053"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-220812014714446053"
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
