
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "e98c2yjtmbyrxlo7y4gdrloey60bshtwzgjs4lusb"
  token_secret = "v6j76qlrcq2a7t4uuz1i0ibulelcrmetinnsq4vad"
}
