
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221218743111"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230316221218743111"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                    = "acctestimg230316221218743111"
  gallery_name            = azurerm_shared_image_gallery.test.name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  os_type                 = "Linux"
  hyper_v_generation      = "V2"
  confidential_vm_enabled = true

  identifier {
    publisher = "AccTesPublisher230316221218743111"
    offer     = "AccTesOffer230316221218743111"
    sku       = "AccTesSku230316221218743111"
  }
}
