

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025816932953"
  location = "West Europe"
}

resource "azurerm_service_fabric_cluster" "test" {
  name                = "acctest-240119025816932953"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  reliability_level   = "Bronze"
  upgrade_mode        = "Automatic"
  vm_image            = "Windows"
  management_endpoint = "http://example:80"

  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}


resource "azurerm_service_fabric_cluster" "import" {
  name                = azurerm_service_fabric_cluster.test.name
  resource_group_name = azurerm_service_fabric_cluster.test.resource_group_name
  location            = azurerm_service_fabric_cluster.test.location
  reliability_level   = azurerm_service_fabric_cluster.test.reliability_level
  upgrade_mode        = azurerm_service_fabric_cluster.test.upgrade_mode
  vm_image            = azurerm_service_fabric_cluster.test.vm_image
  management_endpoint = azurerm_service_fabric_cluster.test.management_endpoint

  node_type {
    name                 = "first"
    instance_count       = 3
    is_primary           = true
    client_endpoint_port = 2020
    http_endpoint_port   = 80
  }
}
