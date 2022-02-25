
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034722755044"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest9jd93"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
