
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004645210734"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-210924004645210734"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
