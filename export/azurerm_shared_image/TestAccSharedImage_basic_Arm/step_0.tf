
provider "azurerm" {
  features {}
}

variable "architecture" {
  default = "Arm64"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013238935137"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238935137"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg221111013238935137"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  architecture        = var.architecture != "" ? var.architecture : null
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "AccTesPublisher221111013238935137"
    offer     = "AccTesOffer221111013238935137"
    sku       = "AccTesSku221111013238935137"
  }
}
