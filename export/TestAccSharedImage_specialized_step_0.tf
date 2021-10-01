
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V1"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020609163498"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211001020609163498"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg211001020609163498"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher211001020609163498"
    offer     = "AccTesOffer211001020609163498"
    sku       = "AccTesSku211001020609163498"
  }
}
