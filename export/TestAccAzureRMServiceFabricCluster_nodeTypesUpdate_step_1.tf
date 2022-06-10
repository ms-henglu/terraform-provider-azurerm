
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610023125135525"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-220610023125135525"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "http://example:80"

  node_type {
    name                 = "first"
    instance_count       = 4
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}
