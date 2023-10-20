
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040746249169"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231020040746249169"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                    = "acctestimg231020040746249169"
  gallery_name            = azurerm_shared_image_gallery.test.name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  os_type                 = "Linux"
  hyper_v_generation      = "V2"
  confidential_vm_enabled = true

  identifier {
    publisher = "AccTesPublisher231020040746249169"
    offer     = "AccTesOffer231020040746249169"
    sku       = "AccTesSku231020040746249169"
  }
}
