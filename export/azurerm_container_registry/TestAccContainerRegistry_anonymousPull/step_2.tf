
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230707003619892901"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                   = "testacccr230707003619892901"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  sku                    = "Standard"
  anonymous_pull_enabled = "true"
}
