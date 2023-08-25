
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024235241716"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230825024235241716"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                    = "acctestimg230825024235241716"
  gallery_name            = azurerm_shared_image_gallery.test.name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  os_type                 = "Linux"
  hyper_v_generation      = "V2"
  confidential_vm_enabled = true

  identifier {
    publisher = "AccTesPublisher230825024235241716"
    offer     = "AccTesOffer230825024235241716"
    sku       = "AccTesSku230825024235241716"
  }
}
