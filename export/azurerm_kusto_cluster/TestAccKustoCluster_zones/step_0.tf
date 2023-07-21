
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011839775984"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkceqqpe"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  zones = ["1"]
}
