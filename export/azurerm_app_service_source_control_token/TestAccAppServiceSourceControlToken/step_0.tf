
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "1ze98v71y7dqph8qrifq2zsyldhikcaz13u48xdsf"
  token_secret = "40lbfkdzigjoocll1wym7lz4c3uufud7su3jz479u"
}
