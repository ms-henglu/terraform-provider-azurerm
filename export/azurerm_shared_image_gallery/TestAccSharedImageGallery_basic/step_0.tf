
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230324051802716133"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230324051802716133"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
