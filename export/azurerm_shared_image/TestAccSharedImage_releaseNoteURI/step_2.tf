
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407023100161714"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230407023100161714"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230407023100161714"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  release_note_uri    = "https://test.com/changelog2.md"

  identifier {
    publisher = "AccTesPublisher230407023100161714"
    offer     = "AccTesOffer230407023100161714"
    sku       = "AccTesSku230407023100161714"
  }
}
