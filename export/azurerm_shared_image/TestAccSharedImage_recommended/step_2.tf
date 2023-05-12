
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404761338"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230512010404761338"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230512010404761338"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 4
  min_recommended_vcpu_count   = 3
  max_recommended_memory_in_gb = 2
  min_recommended_memory_in_gb = 1

  identifier {
    publisher = "AccTesPublisher230512010404761338"
    offer     = "AccTesOffer230512010404761338"
    sku       = "AccTesSku230512010404761338"
  }
}
