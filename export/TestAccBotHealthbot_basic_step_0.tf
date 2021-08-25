

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-210825025555537187"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-210825025555537187"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}
