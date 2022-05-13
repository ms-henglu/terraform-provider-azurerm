
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180415295710"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                      = "acctestkck6n2u"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  double_encryption_enabled = true

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
