
provider "azurerm" {
  features {}
}

variable "architecture" {
  default = "Arm64"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002453899594"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220826002453899594"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220826002453899594"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  architecture        = var.architecture != "" ? var.architecture : null
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "AccTesPublisher220826002453899594"
    offer     = "AccTesOffer220826002453899594"
    sku       = "AccTesSku220826002453899594"
  }
}
