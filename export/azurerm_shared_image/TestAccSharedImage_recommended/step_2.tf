
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604021427"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033604021427"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg231016033604021427"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 4
  min_recommended_vcpu_count   = 3
  max_recommended_memory_in_gb = 2
  min_recommended_memory_in_gb = 1

  identifier {
    publisher = "AccTesPublisher231016033604021427"
    offer     = "AccTesOffer231016033604021427"
    sku       = "AccTesSku231016033604021427"
  }
}
