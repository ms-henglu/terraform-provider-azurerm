
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074443053150"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                         = "acctestavset-230616074443053150"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  platform_update_domain_count = 3
  platform_fault_domain_count  = 3
}
