
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936436110"
  location = "West Europe"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
