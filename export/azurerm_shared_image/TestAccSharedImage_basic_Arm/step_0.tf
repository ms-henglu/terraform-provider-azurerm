
provider "azurerm" {
  features {}
}

variable "architecture" {
  default = "Arm64"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626252674"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230804025626252674"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230804025626252674"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  architecture        = var.architecture != "" ? var.architecture : null
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "AccTesPublisher230804025626252674"
    offer     = "AccTesOffer230804025626252674"
    sku       = "AccTesSku230804025626252674"
  }
}
