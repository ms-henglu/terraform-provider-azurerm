
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "cdrq44lcw9e8ysvdn7xvhtmia28qgdt60ndcyptn4"
  token_secret = "gslghcqbrtjdatsrjqizna113j1vsevydiw0hkrpq"
}
