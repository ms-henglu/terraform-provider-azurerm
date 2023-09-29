


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065913396091"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230929065913396091"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ase" {
  name                 = "asesubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gatewaysubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_app_service_environment" "test" {
  name                = "acctest-ase-230929065913396091"
  subnet_id           = azurerm_subnet.ase.id
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_app_service_environment" "import" {
  name                = azurerm_app_service_environment.test.name
  subnet_id           = azurerm_app_service_environment.test.subnet_id
  resource_group_name = azurerm_app_service_environment.test.resource_group_name
}
