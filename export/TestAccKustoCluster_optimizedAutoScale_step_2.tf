
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044916627439"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc7fwr4"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name = "Standard_D11_v2"
  }

  optimized_auto_scale {
    minimum_instances = 3
    maximum_instances = 4
  }
}
