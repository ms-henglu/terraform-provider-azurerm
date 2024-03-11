
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031615604008"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240311031615604008"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
