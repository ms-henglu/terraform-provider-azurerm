
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220811053013424494"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220811053013424494"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220811053013424494"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 4
  min_recommended_vcpu_count   = 3
  max_recommended_memory_in_gb = 2
  min_recommended_memory_in_gb = 1

  identifier {
    publisher = "AccTesPublisher220811053013424494"
    offer     = "AccTesOffer220811053013424494"
    sku       = "AccTesSku220811053013424494"
  }
}
