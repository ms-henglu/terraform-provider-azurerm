
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-230106031750816750"
  location = "West Europe"
}

resource "azurerm_ip_group" "test" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
