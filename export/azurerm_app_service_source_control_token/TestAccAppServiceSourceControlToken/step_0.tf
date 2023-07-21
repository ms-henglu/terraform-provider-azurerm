
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "8ywsh1twlg3g01jdn3aymdcl8yy4gd8xlwtwf0f4v"
  token_secret = "vbk860a6urnkjskj6nd8zlj3bflg1m1jcbt2yujde"
}
