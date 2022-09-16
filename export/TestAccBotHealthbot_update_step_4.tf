

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-220916011142091364"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-220916011142091364"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}
