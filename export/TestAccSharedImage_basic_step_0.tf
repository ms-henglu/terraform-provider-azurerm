
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = ""
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527033935757570"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220527033935757570"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220527033935757570"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher220527033935757570"
    offer     = "AccTesOffer220527033935757570"
    sku       = "AccTesSku220527033935757570"
  }
}
