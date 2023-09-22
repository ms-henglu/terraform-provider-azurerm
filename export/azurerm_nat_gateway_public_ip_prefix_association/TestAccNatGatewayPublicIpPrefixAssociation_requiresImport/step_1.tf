


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ngpi-230922054621695452"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicIPPrefix-230922054621695452"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 30
  zones               = ["1"]
}


resource "azurerm_nat_gateway" "test" {
  name                = "acctest-NatGateway-230922054621695452"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "test" {
  nat_gateway_id      = azurerm_nat_gateway.test.id
  public_ip_prefix_id = azurerm_public_ip_prefix.test.id
}


resource "azurerm_nat_gateway_public_ip_prefix_association" "import" {
  nat_gateway_id      = azurerm_nat_gateway_public_ip_prefix_association.test.nat_gateway_id
  public_ip_prefix_id = azurerm_nat_gateway_public_ip_prefix_association.test.public_ip_prefix_id
}
