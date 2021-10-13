
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = ""
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071641593653"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211013071641593653"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg211013071641593653"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher211013071641593653"
    offer     = "AccTesOffer211013071641593653"
    sku       = "AccTesSku211013071641593653"
  }
}
