
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324163702031319"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest4ji6r"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
