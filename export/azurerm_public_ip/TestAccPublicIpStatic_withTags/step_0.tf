
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003165593"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-221111014003165593"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
