
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063504069525"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240105063504069525"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                     = "acctestimg240105063504069525"
  gallery_name             = azurerm_shared_image_gallery.test.name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  os_type                  = "Linux"
  hyper_v_generation       = "V2"
  trusted_launch_supported = true

  identifier {
    publisher = "AccTesPublisher240105063504069525"
    offer     = "AccTesOffer240105063504069525"
    sku       = "AccTesSku240105063504069525"
  }
}
