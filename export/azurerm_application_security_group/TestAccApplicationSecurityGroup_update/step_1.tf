
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527640116"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-240119025527640116"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
