
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V1"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014023152930"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211015014023152930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg211015014023152930"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher211015014023152930"
    offer     = "AccTesOffer211015014023152930"
    sku       = "AccTesSku211015014023152930"
  }
}
