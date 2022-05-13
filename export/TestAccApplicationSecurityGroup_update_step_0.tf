
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513023611425624"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-220513023611425624"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
