
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "0gbmkypc7rhqpn6ibj92fefdnoze0bp0anm2vo62e"
  token_secret = "y3rhe0f3anumxn01dmcdiiy9q49crwusadl6ucu62"
}
