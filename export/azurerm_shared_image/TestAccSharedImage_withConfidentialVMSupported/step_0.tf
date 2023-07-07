
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003540141705"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230707003540141705"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                      = "acctestimg230707003540141705"
  gallery_name              = azurerm_shared_image_gallery.test.name
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  os_type                   = "Linux"
  hyper_v_generation        = "V2"
  confidential_vm_supported = true

  identifier {
    publisher = "AccTesPublisher230707003540141705"
    offer     = "AccTesOffer230707003540141705"
    sku       = "AccTesSku230707003540141705"
  }
}
