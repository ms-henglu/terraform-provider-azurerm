
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034403194365"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221222034403194365"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
