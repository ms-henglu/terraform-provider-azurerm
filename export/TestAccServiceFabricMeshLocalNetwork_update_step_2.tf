
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfm-211210035410814784"
  location = "West Europe"
}

resource "azurerm_service_fabric_mesh_local_network" "test" {
  name                   = "accTest-211210035410814784"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  network_address_prefix = "10.1.0.0/22"
  description            = "Test Description"

  tags = {
    Hello = "World"
  }
}
