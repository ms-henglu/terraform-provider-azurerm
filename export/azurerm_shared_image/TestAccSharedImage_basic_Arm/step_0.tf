
provider "azurerm" {
  features {}
}

variable "architecture" {
  default = "Arm64"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604026232"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033604026232"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg231016033604026232"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  architecture        = var.architecture != "" ? var.architecture : null
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "AccTesPublisher231016033604026232"
    offer     = "AccTesOffer231016033604026232"
    sku       = "AccTesSku231016033604026232"
  }
}
