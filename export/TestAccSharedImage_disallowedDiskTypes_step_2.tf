
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011219832100"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220916011219832100"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220916011219832100"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  disk_types_not_allowed = [
    "Standard_LRS",
    "Premium_LRS",
  ]

  identifier {
    publisher = "AccTesPublisher220916011219832100"
    offer     = "AccTesOffer220916011219832100"
    sku       = "AccTesSku220916011219832100"
  }
}
