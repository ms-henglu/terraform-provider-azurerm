
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021839851672"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230421021839851672"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                      = "acctestimg230421021839851672"
  gallery_name              = azurerm_shared_image_gallery.test.name
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  os_type                   = "Linux"
  hyper_v_generation        = "V2"
  confidential_vm_supported = true

  identifier {
    publisher = "AccTesPublisher230421021839851672"
    offer     = "AccTesOffer230421021839851672"
    sku       = "AccTesSku230421021839851672"
  }
}
