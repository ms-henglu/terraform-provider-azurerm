
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4gh49nvaj89dahiga430w0w1vsdv3oqmrtj4odnfn"
  token_secret = "y81izj3e9jvvu28qb4iv91ug6sdofwj1vcbiedk0t"
}
