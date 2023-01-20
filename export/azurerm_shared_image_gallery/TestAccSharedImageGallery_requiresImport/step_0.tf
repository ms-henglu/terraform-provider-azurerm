
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054357246555"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230120054357246555"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
