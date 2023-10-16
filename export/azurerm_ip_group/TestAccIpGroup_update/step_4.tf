
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-231016034430961477"
  location = "West Europe"
}

resource "azurerm_ip_group" "test" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["172.16.240.0/20"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
