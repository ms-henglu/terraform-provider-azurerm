
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728032803929329"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-230728032803929329"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
