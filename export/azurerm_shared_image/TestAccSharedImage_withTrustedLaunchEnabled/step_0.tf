
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404750291"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230512010404750291"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                   = "acctestimg230512010404750291"
  gallery_name           = azurerm_shared_image_gallery.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = "AccTesPublisher230512010404750291"
    offer     = "AccTesOffer230512010404750291"
    sku       = "AccTesSku230512010404750291"
  }
}
