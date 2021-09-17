


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917032023381462"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet210917032023381462"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}


resource "azurerm_subnet" "import" {
  name                 = azurerm_subnet.test.name
  resource_group_name  = azurerm_subnet.test.resource_group_name
  virtual_network_name = azurerm_subnet.test.virtual_network_name
  address_prefix       = azurerm_subnet.test.address_prefix
}
