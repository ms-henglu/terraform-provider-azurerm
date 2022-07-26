
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "j3ahjc4y70avli0arajhm8wfq9ciytlpnzn0892la"
  token_secret = "ifrpz8i7fwq84nt8jije7a20fvuf0py37f6b63cqd"
}
