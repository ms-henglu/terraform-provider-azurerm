
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044542496873"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc2lti8"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
  engine = "V3"
}
