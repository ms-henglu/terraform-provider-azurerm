
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825025624752172"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210825025624752172"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
