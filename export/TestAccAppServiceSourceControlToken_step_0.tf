
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "e24ejf2rlw3djhf0el1x33ki4421rumnx3sqbrpo8"
  token_secret = "rd6ajj93d7bkv87ihd032txcuvcwm6gt1tnjw94qh"
}
