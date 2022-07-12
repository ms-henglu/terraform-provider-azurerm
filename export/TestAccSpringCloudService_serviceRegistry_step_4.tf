
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220712042823092513"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                     = "acctest-sc-220712042823092513"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  sku_name                 = "E0"
  service_registry_enabled = false
}
