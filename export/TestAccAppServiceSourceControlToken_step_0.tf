
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "92h2v41kp37so4e0om38yq07u8dpblrp2mn09uro8"
  token_secret = "bjic3f7m9swukt024bl4pqrml3dz9s9ydictmox8h"
}
