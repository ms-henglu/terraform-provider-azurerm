

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-231218071435436685"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctestDHG-compute-231218071435436685"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}

resource "azurerm_dedicated_host_group" "import" {
  resource_group_name         = azurerm_dedicated_host_group.test.resource_group_name
  name                        = azurerm_dedicated_host_group.test.name
  location                    = azurerm_dedicated_host_group.test.location
  platform_fault_domain_count = 2
}
