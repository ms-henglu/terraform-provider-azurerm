
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "tckqdk2llgudpy89w48ugk1acuf80g6zqcclstqsh"
  token_secret = "u9u8c4mdnwf9wbhreukidz7pg3q9rhcfqxeeu1l4z"
}
