


provider "azurerm" {
  features {}
  # In Vmware acctest, please disable correlation request id, else the continuous operations like update or delete will not be triggered
  # issue https://github.com/Azure/azure-rest-api-specs/issues/14086 
  disable_correlation_request_id = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-Vmware-230316222452705272"
  location = "West Europe"
}


resource "azurerm_vmware_private_cloud" "test" {
  name                = "acctest-PC-230316222452705272"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "av36"

  management_cluster {
    size = 3
  }
  network_subnet_cidr = "192.168.48.0/22"
}


resource "azurerm_vmware_private_cloud" "import" {
  name                = azurerm_vmware_private_cloud.test.name
  resource_group_name = azurerm_vmware_private_cloud.test.resource_group_name
  location            = azurerm_vmware_private_cloud.test.location
  sku_name            = azurerm_vmware_private_cloud.test.sku_name

  management_cluster {
    size = azurerm_vmware_private_cloud.test.management_cluster.0.size
  }
  network_subnet_cidr = azurerm_vmware_private_cloud.test.network_subnet_cidr
}
