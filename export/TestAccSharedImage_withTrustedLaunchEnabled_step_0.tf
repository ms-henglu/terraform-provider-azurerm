
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527033935750668"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220527033935750668"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                   = "acctestimg220527033935750668"
  gallery_name           = azurerm_shared_image_gallery.test.name
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  os_type                = "Linux"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true

  identifier {
    publisher = "AccTesPublisher220527033935750668"
    offer     = "AccTesOffer220527033935750668"
    sku       = "AccTesSku220527033935750668"
  }
}
