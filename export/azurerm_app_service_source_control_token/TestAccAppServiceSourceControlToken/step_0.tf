
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "gmd6nkiee9ujprlrgcpbt8ogcpxvj497rax9gcg7p"
  token_secret = "0lioj7e1ui81p2qi2bw4pan83tsijlnx122akopkx"
}
