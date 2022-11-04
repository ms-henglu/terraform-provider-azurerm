
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "fj2nmjoad3j0zcz7j3tnhlmp0bdr86crolr3z76xk"
  token_secret = "q1ni9889blboadztblgx2dsc2cqgyyh8idwowypz8"
}
