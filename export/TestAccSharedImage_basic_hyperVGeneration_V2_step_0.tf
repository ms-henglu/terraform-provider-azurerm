
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V2"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022336697920"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220610022336697920"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220610022336697920"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher220610022336697920"
    offer     = "AccTesOffer220610022336697920"
    sku       = "AccTesSku220610022336697920"
  }
}
