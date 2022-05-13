
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513180620504949"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-220513180620504949"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
