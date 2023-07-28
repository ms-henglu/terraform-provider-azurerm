

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ngpi-230728032803944835"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-PIP-230728032803944835"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_nat_gateway" "test" {
  name                = "acctest-NatGateway-230728032803944835"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
  tags = {
    Hello = "World"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "test" {
  nat_gateway_id       = azurerm_nat_gateway.test.id
  public_ip_address_id = azurerm_public_ip.test.id
}
