
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231107515118"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkch3u8f"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name = "Standard_D11_v2"
  }

  optimized_auto_scale {
    minimum_instances = 2
    maximum_instances = 3
  }
}
