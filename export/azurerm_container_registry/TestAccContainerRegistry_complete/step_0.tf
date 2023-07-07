
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230707010154920035"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230707010154920035"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  admin_enabled       = false
  sku                 = "Basic"

  tags = {
    environment = "production"
  }
}
