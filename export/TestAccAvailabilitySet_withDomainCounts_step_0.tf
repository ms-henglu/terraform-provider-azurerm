
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324180045266492"
  location = "West Europe"
}

resource "azurerm_availability_set" "test" {
  name                         = "acctestavset-220324180045266492"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  platform_update_domain_count = 3
  platform_fault_domain_count  = 3
}
