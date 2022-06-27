

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-220627132209969222"
  location = "West Europe"
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-220627132209969222"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-pip-220627132209969222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-220627132209969222"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.5.1.0/24"
}


resource "azurerm_virtual_hub_ip" "test" {
  name           = "acctest-vhubipconfig-220627132209969222"
  virtual_hub_id = azurerm_virtual_hub.test.id
  subnet_id      = azurerm_subnet.test.id
}
