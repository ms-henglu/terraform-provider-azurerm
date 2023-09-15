
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024213869178"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                              = "acctest-230915024213869178"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  reliability_level                 = "Bronze"
  upgrade_mode                      = "Automatic"
  vm_image                          = "Windows"
  management_endpoint               = "http://example:80"
  service_fabric_zonal_upgrade_mode = "Hierarchical"
  vmss_zonal_upgrade_mode           = "Parallel"

  node_type {
    name                        = "first"
    instance_count              = 3
    is_primary                  = true
    client_endpoint_port        = 2020
    http_endpoint_port          = 80
    multiple_availability_zones = true
  }
}
