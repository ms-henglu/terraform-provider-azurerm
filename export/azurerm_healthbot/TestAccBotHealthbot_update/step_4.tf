

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-221021033835011094"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-221021033835011094"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}
