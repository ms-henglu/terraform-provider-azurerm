
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-230804025626123538"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-compute-230804025626123538"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}
