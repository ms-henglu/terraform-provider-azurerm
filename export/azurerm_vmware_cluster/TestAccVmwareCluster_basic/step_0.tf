


provider "azurerm" {
  features {}
  # In Vmware acctest, please disable correlation request id, else the continuous operations like update or delete will not be triggered
  # issue https://github.com/Azure/azure-rest-api-specs/issues/14086 
  disable_correlation_request_id = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-Vmware-230915024353821786"
  location = "West Europe"
}


resource "azurerm_vmware_private_cloud" "test" {
  name                = "acctest-PC-230915024353821786"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "av36"

  management_cluster {
    size = 3
  }
  network_subnet_cidr = "192.168.48.0/22"
}


resource "azurerm_vmware_cluster" "test" {
  name               = "acctest-Cluster-230915024353821786"
  vmware_cloud_id    = azurerm_vmware_private_cloud.test.id
  cluster_node_count = 3
  sku_name           = "av36"
}
