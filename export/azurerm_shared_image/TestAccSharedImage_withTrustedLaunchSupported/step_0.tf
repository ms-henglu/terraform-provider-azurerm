
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021734531820"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119021734531820"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                     = "acctestimg240119021734531820"
  gallery_name             = azurerm_shared_image_gallery.test.name
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  os_type                  = "Linux"
  hyper_v_generation       = "V2"
  trusted_launch_supported = true

  identifier {
    publisher = "AccTesPublisher240119021734531820"
    offer     = "AccTesOffer240119021734531820"
    sku       = "AccTesSku240119021734531820"
  }
}
