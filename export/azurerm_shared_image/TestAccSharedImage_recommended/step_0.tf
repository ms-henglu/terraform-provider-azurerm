
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013238937801"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238937801"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg221111013238937801"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 8
  min_recommended_vcpu_count   = 7
  max_recommended_memory_in_gb = 6
  min_recommended_memory_in_gb = 5

  identifier {
    publisher = "AccTesPublisher221111013238937801"
    offer     = "AccTesOffer221111013238937801"
    sku       = "AccTesSku221111013238937801"
  }
}
