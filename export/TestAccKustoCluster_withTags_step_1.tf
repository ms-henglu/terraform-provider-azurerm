
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034311010335"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcxqyu8"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  tags = {
    label = "test1"
    ENV   = "prod"
  }
}
