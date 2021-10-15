
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = ""
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014023154238"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211015014023154238"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg211015014023154238"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher211015014023154238"
    offer     = "AccTesOffer211015014023154238"
    sku       = "AccTesSku211015014023154238"
  }
}
