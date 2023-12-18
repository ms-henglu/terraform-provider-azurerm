
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256300217"
  location = "West Europe"
}

resource "azurerm_application_security_group" "test" {
  name                = "acctest-231218072256300217"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
