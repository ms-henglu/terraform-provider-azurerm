

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014613808076"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220726014613808076"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_shared_image_gallery" "import" {
  name                = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_shared_image_gallery.test.resource_group_name
  location            = azurerm_shared_image_gallery.test.location
}
