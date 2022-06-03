
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "zgwsiutzy7fd0607ueuw7ktfxje9zwwucgp9r4ef7"
  token_secret = "jn7jmqeq2h0ibmxsothwf22dk3q80juvw7brcoqny"
}
