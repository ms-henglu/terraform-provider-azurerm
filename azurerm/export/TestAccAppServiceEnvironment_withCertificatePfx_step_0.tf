


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627123144782131"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-220627123144782131"
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
  name      = "acctest-ase-220627123144782131"
  subnet_id = azurerm_subnet.ase.id
}


resource "azurerm_app_service_certificate" "test" {
  name                           = "acctest-cert-220627123144782131"
  resource_group_name            = azurerm_app_service_environment.test.resource_group_name
  location                       = azurerm_resource_group.test.location
  pfx_blob                       = filebase64("testdata/app_service_certificate.pfx")
  password                       = "terraform"
  hosting_environment_profile_id = azurerm_app_service_environment.test.id
}
