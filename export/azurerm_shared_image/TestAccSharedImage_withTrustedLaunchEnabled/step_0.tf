
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171853891883"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221028171853891883"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                   = "acctestimg221028171853891883"
  gallery_name           = azurerm_shared_image_gallery.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = "AccTesPublisher221028171853891883"
    offer     = "AccTesOffer221028171853891883"
    sku       = "AccTesSku221028171853891883"
  }
}
