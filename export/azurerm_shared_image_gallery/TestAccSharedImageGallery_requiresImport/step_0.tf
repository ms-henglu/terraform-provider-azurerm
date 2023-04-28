
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045412213577"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230428045412213577"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
