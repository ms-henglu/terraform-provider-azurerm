
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050831100676"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone211119050831100676.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
