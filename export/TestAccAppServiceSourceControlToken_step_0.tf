
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "omuf0akovkfgo08cob4067d698g4fdj6ee49diy1j"
  token_secret = "370k8y8p8m3hp68anvs2jte43pka1zkg4qjltcuun"
}
