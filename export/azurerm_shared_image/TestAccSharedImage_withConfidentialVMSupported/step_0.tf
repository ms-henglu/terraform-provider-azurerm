
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074443134330"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230616074443134330"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                      = "acctestimg230616074443134330"
  gallery_name              = azurerm_shared_image_gallery.test.name
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  os_type                   = "Linux"
  hyper_v_generation        = "V2"
  confidential_vm_supported = true

  identifier {
    publisher = "AccTesPublisher230616074443134330"
    offer     = "AccTesOffer230616074443134330"
    sku       = "AccTesSku230616074443134330"
  }
}
