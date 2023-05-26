
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "d1xychf1msx2uyiubfodr4zc1dtexny4g0pujk6un"
  token_secret = "of38z7azimwkngfhnmlm6pi72n44du6xaxh2tpks7"
}
