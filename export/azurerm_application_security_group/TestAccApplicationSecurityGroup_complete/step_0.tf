
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004444497278"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-230707004444497278"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Hello = "World"
  }
}
