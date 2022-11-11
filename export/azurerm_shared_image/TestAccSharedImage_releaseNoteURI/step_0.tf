
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013238937779"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238937779"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg221111013238937779"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  release_note_uri    = "https://test.com/changelog.md"

  identifier {
    publisher = "AccTesPublisher221111013238937779"
    offer     = "AccTesOffer221111013238937779"
    sku       = "AccTesSku221111013238937779"
  }
}
