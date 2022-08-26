
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-220826002518849042"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                   = "testacccr220826002518849042"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  sku                    = "Standard"
  anonymous_pull_enabled = "true"
}
