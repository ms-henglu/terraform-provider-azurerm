

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-220826002415236794"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-220826002415236794"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}
