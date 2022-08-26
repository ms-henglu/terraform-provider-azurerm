
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002453895311"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220826002453895311"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220826002453895311"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 8
  min_recommended_vcpu_count   = 7
  max_recommended_memory_in_gb = 6
  min_recommended_memory_in_gb = 5

  identifier {
    publisher = "AccTesPublisher220826002453895311"
    offer     = "AccTesOffer220826002453895311"
    sku       = "AccTesSku220826002453895311"
  }
}
