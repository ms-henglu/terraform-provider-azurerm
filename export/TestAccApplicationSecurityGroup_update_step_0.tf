
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072215368407"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-211013072215368407"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
