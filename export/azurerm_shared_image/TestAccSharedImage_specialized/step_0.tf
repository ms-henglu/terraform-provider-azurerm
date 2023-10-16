
provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = "V1"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604027516"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033604027516"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg231016033604027516"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher231016033604027516"
    offer     = "AccTesOffer231016033604027516"
    sku       = "AccTesSku231016033604027516"
  }
}
