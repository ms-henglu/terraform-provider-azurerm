
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707421664"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707421664"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg240119024707421664"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  end_of_life_date = "2024-01-19T22:47:07Z"

  identifier {
    publisher = "AccTesPublisher240119024707421664"
    offer     = "AccTesOffer240119024707421664"
    sku       = "AccTesSku240119024707421664"
  }
}
