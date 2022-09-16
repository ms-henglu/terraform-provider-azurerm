

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-220916011219782966"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220916011219782966"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-220916011219782966"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"

  end_of_life_date = "2022-09-16T21:12:19Z"
}
