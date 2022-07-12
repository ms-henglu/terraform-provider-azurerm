
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042046043678"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220712042046043678"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220712042046043678"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  release_note_uri    = "https://test.com/changelog.md"

  identifier {
    publisher = "AccTesPublisher220712042046043678"
    offer     = "AccTesOffer220712042046043678"
    sku       = "AccTesSku220712042046043678"
  }
}
