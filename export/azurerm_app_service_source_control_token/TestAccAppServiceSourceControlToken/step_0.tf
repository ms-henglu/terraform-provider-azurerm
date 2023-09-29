
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "qhsdmyp8vhov9dt9w31qzwmb4zapd6wsu8q44cpgo"
  token_secret = "hrh6oe4hxk7i9dpscamzeft2pzg30sxgb9am6v28b"
}
