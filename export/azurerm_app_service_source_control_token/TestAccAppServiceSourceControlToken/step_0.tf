
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "edib9p3x73zv0qsksoq7p4r0u4qeeeczhe1of7a3i"
  token_secret = "xyyzteshg034wh0s29fx926f4gak6qgpxdr0mwwly"
}
