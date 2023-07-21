
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721012147134320"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-230721012147134320"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
