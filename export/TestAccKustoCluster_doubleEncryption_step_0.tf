
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065636049119"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                      = "acctestkc13swa"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  double_encryption_enabled = true

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
