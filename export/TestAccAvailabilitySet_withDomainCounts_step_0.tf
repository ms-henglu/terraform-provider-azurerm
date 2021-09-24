
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004029370012"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                         = "acctestavset-210924004029370012"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  platform_update_domain_count = 3
  platform_fault_domain_count  = 3
}
