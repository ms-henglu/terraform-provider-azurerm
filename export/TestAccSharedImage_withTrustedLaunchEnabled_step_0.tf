
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030257351662"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220415030257351662"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                   = "acctestimg220415030257351662"
  gallery_name           = azurerm_shared_image_gallery.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = "AccTesPublisher220415030257351662"
    offer     = "AccTesOffer220415030257351662"
    sku       = "AccTesSku220415030257351662"
  }
}
