
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230313021738410290"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-rg-230313021738410290"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_private_dns_resolver" "test" {
  name                = "acctest-dr-230313021738410290"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_network_id  = azurerm_virtual_network.test.id
  tags = {
    key = "value"
  }
}
