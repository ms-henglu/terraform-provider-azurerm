
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604022310"
  location = "West Europe"
}
resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033604022310"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
resource "azurerm_shared_image" "test" {
  name                = "acctestimg231016033604022310"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  identifier {
    publisher = "AccTesPublisher231016033604022310"
    offer     = "AccTesOffer231016033604022310"
    sku       = "AccTesSku231016033604022310"
  }
}
