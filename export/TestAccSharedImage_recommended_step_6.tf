
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220715004235787150"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220715004235787150"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220715004235787150"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 8
  min_recommended_vcpu_count   = 7
  max_recommended_memory_in_gb = 6
  min_recommended_memory_in_gb = 5

  identifier {
    publisher = "AccTesPublisher220715004235787150"
    offer     = "AccTesOffer220715004235787150"
    sku       = "AccTesSku220715004235787150"
  }
}
