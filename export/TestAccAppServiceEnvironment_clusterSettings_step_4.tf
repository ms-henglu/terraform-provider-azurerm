

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015015256058379"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-211015015256058379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ase" {
  name                 = "asesubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "gateway" {
  name                 = "gatewaysubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}


resource "azurerm_app_service_environment" "test" {
  name      = "acctest-ase-211015015256058379"
  subnet_id = azurerm_subnet.ase.id

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }
}
