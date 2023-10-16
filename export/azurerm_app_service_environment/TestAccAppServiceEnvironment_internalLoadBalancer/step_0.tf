

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034930981173"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-231016034930981173"
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
  name                         = "acctest-ase-231016034930981173"
  subnet_id                    = azurerm_subnet.ase.id
  resource_group_name          = azurerm_resource_group.test.name
  pricing_tier                 = "I1"
  front_end_scale_factor       = 5
  internal_load_balancing_mode = "Web, Publishing"
  allowed_user_ip_cidrs        = ["11.22.33.44/32", "55.66.77.0/24"]
}
