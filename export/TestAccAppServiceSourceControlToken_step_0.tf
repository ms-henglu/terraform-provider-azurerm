
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "dt7c6zt09476wptuklquwkeb0o6plqo1b6govgfp9"
  token_secret = "4od8nlpa0w8l970audtslrjzrctvxm46qhiutpsrh"
}
