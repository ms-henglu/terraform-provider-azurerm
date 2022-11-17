
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231247874105"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-221117231247874105"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
