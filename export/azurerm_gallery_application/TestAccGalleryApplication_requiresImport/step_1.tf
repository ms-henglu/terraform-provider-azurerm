


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230127045135594582"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230127045135594582"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-230127045135594582"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"
}


resource "azurerm_gallery_application" "import" {
  name              = azurerm_gallery_application.test.name
  gallery_id        = azurerm_gallery_application.test.gallery_id
  location          = azurerm_gallery_application.test.location
  supported_os_type = azurerm_gallery_application.test.supported_os_type
}
