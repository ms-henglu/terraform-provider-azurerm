
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "27tvqg6thc0a7dikugtva1jro1lekx62izls8bvxb"
  token_secret = "nmrth69jpb9bad9uorxiqp8uhndxkt2mlmrvvflws"
}
