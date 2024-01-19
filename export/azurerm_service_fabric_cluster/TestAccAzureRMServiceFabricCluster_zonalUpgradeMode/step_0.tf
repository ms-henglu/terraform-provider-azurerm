
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025816940510"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                              = "acctest-240119025816940510"
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
