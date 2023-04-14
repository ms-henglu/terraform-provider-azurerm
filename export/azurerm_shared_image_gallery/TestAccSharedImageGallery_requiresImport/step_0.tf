
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020945135137"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230414020945135137"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
