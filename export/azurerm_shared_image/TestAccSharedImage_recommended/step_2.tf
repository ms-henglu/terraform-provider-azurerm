
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707424148"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707424148"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg240119024707424148"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  max_recommended_vcpu_count   = 4
  min_recommended_vcpu_count   = 3
  max_recommended_memory_in_gb = 2
  min_recommended_memory_in_gb = 1

  identifier {
    publisher = "AccTesPublisher240119024707424148"
    offer     = "AccTesOffer240119024707424148"
    sku       = "AccTesSku240119024707424148"
  }
}
