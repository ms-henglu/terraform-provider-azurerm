


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-230929065414990973"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230929065414990973"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctest-230929065414990973"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_nat_gateway_association" "test" {
  subnet_id      = azurerm_subnet.test.id
  nat_gateway_id = azurerm_nat_gateway.test.id
}


resource "azurerm_subnet_nat_gateway_association" "import" {
  subnet_id      = azurerm_subnet_nat_gateway_association.test.subnet_id
  nat_gateway_id = azurerm_subnet_nat_gateway_association.test.nat_gateway_id
}
