
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "spl7nv0gtvgtkxoqiug8nd7awa0fm486khmmflrmz"
  token_secret = "teq13rery6sitr2x28nqvwu6aslre9vqw4o0u4n76"
}
