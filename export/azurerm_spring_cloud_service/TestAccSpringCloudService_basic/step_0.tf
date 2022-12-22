
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-221222035354003851"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-221222035354003851"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
