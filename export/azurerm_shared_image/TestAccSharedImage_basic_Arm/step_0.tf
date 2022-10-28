
provider "azurerm" {
  features {}
}

variable "architecture" {
  default = "Arm64"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171853897967"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221028171853897967"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg221028171853897967"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  architecture        = var.architecture != "" ? var.architecture : null
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "AccTesPublisher221028171853897967"
    offer     = "AccTesOffer221028171853897967"
    sku       = "AccTesSku221028171853897967"
  }
}
