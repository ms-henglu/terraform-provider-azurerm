

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-bastion-240119025527651685"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVNetk128g"
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
  name                = "acctestBastionPIP240119025527651685"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "test" {
  name                = "acctestBastionk128g"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                 = "ip-configuration"
    subnet_id            = azurerm_subnet.test.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_bastion_host" "import" {
  name                = azurerm_bastion_host.test.name
  resource_group_name = azurerm_bastion_host.test.resource_group_name
  location            = azurerm_bastion_host.test.location

  ip_configuration {
    name                 = "ip-configuration"
    subnet_id            = azurerm_subnet.test.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
