
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004235782680"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220715004235782680"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220715004235782680"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  disk_types_not_allowed = [
    "Standard_LRS",
    "Premium_LRS",
  ]

  identifier {
    publisher = "AccTesPublisher220715004235782680"
    offer     = "AccTesOffer220715004235782680"
    sku       = "AccTesSku220715004235782680"
  }
}
