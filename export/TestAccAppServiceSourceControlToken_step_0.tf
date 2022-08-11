
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "hgk3ucnl86dq99jw9hb228dk9nx6pw6dwgqzkgstc"
  token_secret = "y32g0zk929frpwbd6ssmtcas3zoprp4j8tamhu2cl"
}
