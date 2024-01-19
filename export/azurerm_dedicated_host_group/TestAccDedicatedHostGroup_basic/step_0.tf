
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-240119024707314506"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-compute-240119024707314506"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}
