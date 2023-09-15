

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023108506046"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230915023108506046"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_shared_image_gallery" "import" {
  name                = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_shared_image_gallery.test.resource_group_name
  location            = azurerm_shared_image_gallery.test.location
}
