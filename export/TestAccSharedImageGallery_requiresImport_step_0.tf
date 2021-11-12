
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112020355800379"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211112020355800379"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
