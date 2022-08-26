
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002453896529"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220826002453896529"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                   = "acctestimg220826002453896529"
  gallery_name           = azurerm_shared_image_gallery.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = "AccTesPublisher220826002453896529"
    offer     = "AccTesOffer220826002453896529"
    sku       = "AccTesSku220826002453896529"
  }
}
