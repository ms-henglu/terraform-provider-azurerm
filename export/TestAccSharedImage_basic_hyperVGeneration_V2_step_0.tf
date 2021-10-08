
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V2"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044203078910"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211008044203078910"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg211008044203078910"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher211008044203078910"
    offer     = "AccTesOffer211008044203078910"
    sku       = "AccTesSku211008044203078910"
  }
}
