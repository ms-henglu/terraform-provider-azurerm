
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063840320134"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-230203063840320134"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
