
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316221218747769"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230316221218747769"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
