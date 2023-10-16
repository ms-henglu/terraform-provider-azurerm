
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-bastion-231016034430951159"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVNetn814j"
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["192.168.1.224/27"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestBastionPIP231016034430951159"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "test" {
  name                = "acctestBastionn814j"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"

  ip_configuration {
    name                 = "ip-configuration"
    subnet_id            = azurerm_subnet.test.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
