


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-240119025527739370"
  location = "West Europe"
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-240119025527739370"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-pip-240119025527739370"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240119025527739370"
  address_space       = ["10.5.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "RouteServerSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]
}


resource "azurerm_virtual_hub_ip" "test" {
  name                 = "acctest-vhubipconfig-240119025527739370"
  virtual_hub_id       = azurerm_virtual_hub.test.id
  public_ip_address_id = azurerm_public_ip.test.id
  subnet_id            = azurerm_subnet.test.id
}


resource "azurerm_virtual_hub_ip" "import" {
  name                 = azurerm_virtual_hub_ip.test.name
  virtual_hub_id       = azurerm_virtual_hub_ip.test.virtual_hub_id
  public_ip_address_id = azurerm_virtual_hub_ip.test.public_ip_address_id
  subnet_id            = azurerm_virtual_hub_ip.test.subnet_id
}
