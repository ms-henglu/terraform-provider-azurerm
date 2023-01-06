
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "yg3wigdw1ewhgzw67szicbfasql3tc1xp1ei7itcs"
  token_secret = "6ef4tez3l9yr8eoleeacwqdw8xggnepbvlc6qvfyb"
}
