
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005727205571"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-221104005727205571"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
