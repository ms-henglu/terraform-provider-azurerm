
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220627135016462728"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220627135016462728"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

