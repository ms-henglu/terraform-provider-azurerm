
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506010050243359"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-220506010050243359"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
