

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-acr-230316221256035605"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr230316221256035605"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}


resource "azurerm_container_registry" "import" {
  name                = azurerm_container_registry.test.name
  resource_group_name = azurerm_container_registry.test.resource_group_name
  location            = azurerm_container_registry.test.location
  sku                 = azurerm_container_registry.test.sku
}
