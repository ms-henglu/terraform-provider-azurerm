
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064556879944"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230929064556879944"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230929064556879944"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  disk_types_not_allowed = [
    "Standard_LRS",
    "Premium_LRS",
  ]

  identifier {
    publisher = "AccTesPublisher230929064556879944"
    offer     = "AccTesOffer230929064556879944"
    sku       = "AccTesSku230929064556879944"
  }
}
