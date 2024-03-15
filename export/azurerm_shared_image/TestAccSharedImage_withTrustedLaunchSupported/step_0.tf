
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122550007445"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240315122550007445"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                     = "acctestimg240315122550007445"
  gallery_name             = azurerm_shared_image_gallery.test.name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  os_type                  = "Linux"
  hyper_v_generation       = "V2"
  trusted_launch_supported = true

  identifier {
    publisher = "AccTesPublisher240315122550007445"
    offer     = "AccTesOffer240315122550007445"
    sku       = "AccTesSku240315122550007445"
  }
}
