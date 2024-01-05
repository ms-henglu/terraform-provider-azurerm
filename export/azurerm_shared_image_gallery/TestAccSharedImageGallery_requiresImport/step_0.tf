
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060444541561"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240105060444541561"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
