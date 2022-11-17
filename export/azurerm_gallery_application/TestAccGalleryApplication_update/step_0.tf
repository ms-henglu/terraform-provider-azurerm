

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-221117230632323496"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221117230632323496"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-221117230632323496"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"
}
