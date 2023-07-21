
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721011329116627"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230721011329116627"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
