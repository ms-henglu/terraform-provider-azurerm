
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2wtszsytmtwzzmj231rp0yjkeora86bfmba6onok2"
  token_secret = "47rqlzoqom76j4xjrexu36ioaxnuwjnf0pak9eavk"
}
