

provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = ""
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924010808666990"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210924010808666990"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg210924010808666990"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher210924010808666990"
    offer     = "AccTesOffer210924010808666990"
    sku       = "AccTesSku210924010808666990"
  }
}


resource "azurerm_shared_image" "import" {
  name                = azurerm_shared_image.test.name
  gallery_name        = azurerm_shared_image.test.gallery_name
  resource_group_name = azurerm_shared_image.test.resource_group_name
  location            = azurerm_shared_image.test.location
  os_type             = azurerm_shared_image.test.os_type

  identifier {
    publisher = "AccTesPublisher210924010808666990"
    offer     = "AccTesOffer210924010808666990"
    sku       = "AccTesSku210924010808666990"
  }
}
