
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V1"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065303872148"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220429065303872148"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220429065303872148"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher220429065303872148"
    offer     = "AccTesOffer220429065303872148"
    sku       = "AccTesSku220429065303872148"
  }
}
