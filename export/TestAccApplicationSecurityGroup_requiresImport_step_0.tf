
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627124517807097"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-220627124517807097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
