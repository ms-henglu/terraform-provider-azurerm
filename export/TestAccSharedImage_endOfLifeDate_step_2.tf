
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011219836630"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220916011219836630"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg220916011219836630"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  end_of_life_date = "2022-09-16T21:12:19Z"

  identifier {
    publisher = "AccTesPublisher220916011219836630"
    offer     = "AccTesOffer220916011219836630"
    sku       = "AccTesSku220916011219836630"
  }
}
