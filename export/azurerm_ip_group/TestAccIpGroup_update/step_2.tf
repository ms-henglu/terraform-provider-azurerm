
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-240315123704022431"
  location = "West Europe"
}

resource "azurerm_ip_group" "test" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["192.168.0.1", "172.16.240.0/20", "10.48.0.0/12"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}

resource "azurerm_ip_group" "test2" {
  name                = "acceptanceTestIpGroup2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["192.168.0.1", "172.16.240.0/20", "10.48.0.0/12"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}

resource "azurerm_ip_group" "test3" {
  name                = "acceptanceTestIpGroup3"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["192.168.0.1", "172.16.240.0/20", "10.48.0.0/12"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
