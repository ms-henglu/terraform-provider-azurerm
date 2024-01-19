
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707425769"
  location = "West Europe"
}
resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707425769"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_shared_image" "test" {
  name                = "acctestimg240119024707425769"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  identifier {
    publisher = "AccTesPublisher240119024707425769"
    offer     = "AccTesOffer240119024707425769"
    sku       = "AccTesSku240119024707425769"
  }
}
