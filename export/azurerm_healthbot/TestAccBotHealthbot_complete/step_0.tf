

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-230804025525892916"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-230804025525892916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "S1"

  tags = {
    ENV = "Test"
  }
}
