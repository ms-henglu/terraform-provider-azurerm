
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035138242933"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                 = "acctest-240112035138242933"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  reliability_level    = "Bronze"
  upgrade_mode         = "Manual"
  cluster_code_version = ""
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
