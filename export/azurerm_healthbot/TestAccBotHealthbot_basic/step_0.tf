

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-healthbot-230512010311021910"
  location = "West Europe"
}


resource "azurerm_healthbot" "test" {
  name                = "acctest-hb-230512010311021910"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "F0"
}
