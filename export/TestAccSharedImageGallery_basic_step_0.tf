
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021234811797399"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211021234811797399"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
