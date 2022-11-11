
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013238937975"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238937975"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg221111013238937975"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  disk_types_not_allowed = [
    "Standard_LRS",
    "Premium_LRS",
  ]

  identifier {
    publisher = "AccTesPublisher221111013238937975"
    offer     = "AccTesOffer221111013238937975"
    sku       = "AccTesSku221111013238937975"
  }
}
