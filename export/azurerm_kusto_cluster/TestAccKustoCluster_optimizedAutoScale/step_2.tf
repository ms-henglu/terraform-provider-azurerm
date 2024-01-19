
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025218617756"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcc1hkp"
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
