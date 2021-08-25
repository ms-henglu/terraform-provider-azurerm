
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-210825032111029307"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-210825032111029307"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

