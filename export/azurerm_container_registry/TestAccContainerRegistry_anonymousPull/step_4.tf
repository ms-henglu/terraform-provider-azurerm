
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-221222034428316502"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                   = "testacccr221222034428316502"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  sku                    = "Standard"
  anonymous_pull_enabled = "false"
}
