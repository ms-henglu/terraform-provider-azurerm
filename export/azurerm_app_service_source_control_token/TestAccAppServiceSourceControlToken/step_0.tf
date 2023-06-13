
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "3gtho4d8hrhtqzi96i6c08wspech0cgb1vabmo4l3"
  token_secret = "hq7xtcjwd2wvdxdopk1kmgc910sgcwjzzp867qawy"
}
