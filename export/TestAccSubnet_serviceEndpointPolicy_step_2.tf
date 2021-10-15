

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014608614600"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet211015014608614600"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-211015014608614600"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_subnet" "test" {
  name                        = "internal"
  resource_group_name         = azurerm_resource_group.test.name
  virtual_network_name        = azurerm_virtual_network.test.name
  address_prefix              = "10.0.2.0/24"
  service_endpoints           = ["Microsoft.Sql"]
  service_endpoint_policy_ids = [azurerm_subnet_service_endpoint_storage_policy.test.id]
}
