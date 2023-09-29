
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064556878360"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230929064556878360"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sharing {
    permission = "Community"
    community_gallery {
      eula            = "https://eula.net"
      prefix          = "prefix"
      publisher_email = "publisher@test.net"
      publisher_uri   = "https://publisher.net"
    }
  }
}
