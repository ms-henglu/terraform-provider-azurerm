
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404759350"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230512010404759350"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230512010404759350"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  end_of_life_date = "2023-05-12T11:04:04Z"

  identifier {
    publisher = "AccTesPublisher230512010404759350"
    offer     = "AccTesOffer230512010404759350"
    sku       = "AccTesSku230512010404759350"
  }
}
