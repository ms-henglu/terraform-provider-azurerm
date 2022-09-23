
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "zvvm6037r8xkz8amtxyub6gwe9t90vcttdgs6qw9p"
  token_secret = "iq2ttrjoyprjru41v4h4yiym1s10wnbcjig6rh7la"
}
