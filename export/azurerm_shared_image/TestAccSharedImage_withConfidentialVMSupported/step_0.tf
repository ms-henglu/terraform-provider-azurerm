
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626251976"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230804025626251976"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                      = "acctestimg230804025626251976"
  gallery_name              = azurerm_shared_image_gallery.test.name
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  os_type                   = "Linux"
  hyper_v_generation        = "V2"
  confidential_vm_supported = true

  identifier {
    publisher = "AccTesPublisher230804025626251976"
    offer     = "AccTesOffer230804025626251976"
    sku       = "AccTesSku230804025626251976"
  }
}
