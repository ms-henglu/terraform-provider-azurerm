

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-240119024707327397"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707327397"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-240119024707327397"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"

  eula = "https://eula2.net"
}
