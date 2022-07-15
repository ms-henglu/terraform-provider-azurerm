
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "yzg8wohdlpjdo6iqu26dgs7x9fey1imo17jwk61nk"
  token_secret = "dbqc9qqdxsnqyf3slkpsnje2x11j8peu7tqabzlpj"
}
