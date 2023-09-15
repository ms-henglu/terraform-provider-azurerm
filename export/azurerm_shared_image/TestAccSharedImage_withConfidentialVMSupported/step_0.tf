
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023108509116"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230915023108509116"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                      = "acctestimg230915023108509116"
  gallery_name              = azurerm_shared_image_gallery.test.name
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  os_type                   = "Linux"
  hyper_v_generation        = "V2"
  confidential_vm_supported = true

  identifier {
    publisher = "AccTesPublisher230915023108509116"
    offer     = "AccTesOffer230915023108509116"
    sku       = "AccTesSku230915023108509116"
  }
}
