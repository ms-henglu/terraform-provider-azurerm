
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014745310492"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkctsptx"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
