
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065303878444"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220429065303878444"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
