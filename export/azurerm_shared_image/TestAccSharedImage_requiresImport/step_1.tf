

provider "azurerm" {
  features {}
}

variable "hyper_v_generation" {
  default = ""
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014716571836"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230721014716571836"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230721014716571836"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  hyper_v_generation  = var.hyper_v_generation != "" ? var.hyper_v_generation : null

  identifier {
    publisher = "AccTesPublisher230721014716571836"
    offer     = "AccTesOffer230721014716571836"
    sku       = "AccTesSku230721014716571836"
  }
}


resource "azurerm_shared_image" "import" {
  name                = azurerm_shared_image.test.name
  gallery_name        = azurerm_shared_image.test.gallery_name
  resource_group_name = azurerm_shared_image.test.resource_group_name
  location            = azurerm_shared_image.test.location
  os_type             = azurerm_shared_image.test.os_type

  identifier {
    publisher = "AccTesPublisher230721014716571836"
    offer     = "AccTesOffer230721014716571836"
    sku       = "AccTesSku230721014716571836"
  }
}
