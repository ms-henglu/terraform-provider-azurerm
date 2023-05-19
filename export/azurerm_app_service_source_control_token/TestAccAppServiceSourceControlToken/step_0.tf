
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "wnn1wkrr1mgmzxhdzzjj31uurv9wikydmet08kpnm"
  token_secret = "3wsp4xj8axkmg430nd2p4ev8niv1fmbs3b3n49w4n"
}
