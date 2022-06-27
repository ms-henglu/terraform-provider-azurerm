
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "eodp3ygdqgs687m2jrj09rhfh4gv9c32by4y619dy"
  token_secret = "xhvoarpzlza9xmv8ebd1kdfsgmueftgp2lzzu1ze3"
}
