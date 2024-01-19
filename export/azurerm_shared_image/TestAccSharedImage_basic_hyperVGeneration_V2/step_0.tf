
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V2"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707419273"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707419273"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg240119024707419273"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher240119024707419273"
    offer     = "AccTesOffer240119024707419273"
    sku       = "AccTesSku240119024707419273"
  }
}
