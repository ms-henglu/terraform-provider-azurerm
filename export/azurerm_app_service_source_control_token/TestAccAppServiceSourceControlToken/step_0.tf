
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "rgwwp2sh3dk03mw1vcmdamg3tex2wq08vsvaifk3p"
  token_secret = "43dpuov17tohqnytg0fjxhsqjpfvbjobvyzst3bv0"
}
