
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917032023322761"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-210917032023322761"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
