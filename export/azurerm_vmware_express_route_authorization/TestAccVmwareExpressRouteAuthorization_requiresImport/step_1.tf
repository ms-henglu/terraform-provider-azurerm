



provider "azurerm" {
  features {}
  # In Vmware acctest, please disable correlation request id, else the continuous operations like update or delete will not be triggered
  # issue https://github.com/Azure/azure-rest-api-specs/issues/14086 
  disable_correlation_request_id = true
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-Vmware-240105064801357702"
  location = "West Europe"
}


resource "azurerm_vmware_private_cloud" "test" {
  name                = "acctest-PC-240105064801357702"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku_name            = "av36"

  management_cluster {
    size = 3
  }
  network_subnet_cidr = "192.168.48.0/22"
}


resource "azurerm_vmware_express_route_authorization" "test" {
  name             = "acctest-VmwareAuthorization-240105064801357702"
  private_cloud_id = azurerm_vmware_private_cloud.test.id
}


resource "azurerm_vmware_express_route_authorization" "import" {
  name             = azurerm_vmware_express_route_authorization.test.name
  private_cloud_id = azurerm_vmware_private_cloud.test.id
}
