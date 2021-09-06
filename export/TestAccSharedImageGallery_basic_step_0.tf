
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210906022054100500"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210906022054100500"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
