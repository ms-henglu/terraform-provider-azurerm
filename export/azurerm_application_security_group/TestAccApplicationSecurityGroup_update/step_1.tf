
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043954276555"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-231013043954276555"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
