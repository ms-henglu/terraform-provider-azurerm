
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "hqnyoxc4af9mms4b1r4czr9jx7ybns1it7y2yxmxx"
  token_secret = "djcfk36vg23ko26k7dqsupxir9mahcdta0n0bjgxw"
}
