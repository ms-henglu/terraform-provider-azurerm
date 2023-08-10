
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143940948271"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-230810143940948271"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
