
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031950556033"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230728031950556033"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
