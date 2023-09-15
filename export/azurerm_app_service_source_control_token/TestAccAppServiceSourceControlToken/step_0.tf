
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "8c9jfmegi799vnyd0ku1ghvssoxwx8423uhzhywpg"
  token_secret = "uxryo7ppkuyicz96e8e382o0k61222ytofi4yz7mk"
}
