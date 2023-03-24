
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "nz288oovpl7yt9rdy4lvw6skb71smylrubpxt3y1a"
  token_secret = "16dy9iy6t7btkd6yt37x2h39mz8wjx1g7khxzil8f"
}
