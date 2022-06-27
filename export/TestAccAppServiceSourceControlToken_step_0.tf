
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "f4lyh10ifhgrkbtfcj9c41y02ud6jrucy9h8yvnbj"
  token_secret = "c10sjnnfofpfokox0pqllvlwbo7r6r0uwx8lfwefu"
}
