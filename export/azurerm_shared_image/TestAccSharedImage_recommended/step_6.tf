
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626252528"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230804025626252528"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230804025626252528"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 8
  min_recommended_vcpu_count   = 7
  max_recommended_memory_in_gb = 6
  min_recommended_memory_in_gb = 5

  identifier {
    publisher = "AccTesPublisher230804025626252528"
    offer     = "AccTesOffer230804025626252528"
    sku       = "AccTesSku230804025626252528"
  }
}
