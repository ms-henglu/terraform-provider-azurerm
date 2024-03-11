
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033114757438"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                 = "acctest-240311033114757438"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  reliability_level    = "Bronze"
  upgrade_mode         = "Manual"
  cluster_code_version = "10.1.1541.9590"
  vm_image             = "Windows"
  management_endpoint  = "http://example:80"

  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}
