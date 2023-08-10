

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230810143140286235"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230810143140286235"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-230810143140286235"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"

  description           = "This is the gallery application description."
  end_of_life_date      = "2023-08-11T00:31:40Z"
  eula                  = "https://eula.net"
  privacy_statement_uri = "https://privacy.statement.net"
  release_note_uri      = "https://release.note.net"

  tags = {
    ENV = "Test"
  }
}
