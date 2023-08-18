
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023718883702"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230818023718883702"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                    = "acctestimg230818023718883702"
  gallery_name            = azurerm_shared_image_gallery.test.name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  os_type                 = "Linux"
  hyper_v_generation      = "V2"
  confidential_vm_enabled = true

  identifier {
    publisher = "AccTesPublisher230818023718883702"
    offer     = "AccTesOffer230818023718883702"
    sku       = "AccTesSku230818023718883702"
  }
}
