

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-221111013238736110"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238736110"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-221111013238736110"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"

  end_of_life_date = "2022-11-11T21:32:38Z"
}
