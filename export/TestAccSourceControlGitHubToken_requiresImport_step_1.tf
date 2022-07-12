

provider "azurerm" {
  features {}
}

resource azurerm_source_control_token test {
  type  = "GitHub"
  token = "ARM_GITHUB_ACCESS_TOKEN"
}


resource azurerm_source_control_token import {
  type  = azurerm_source_control_token.test.type
  token = azurerm_source_control_token.test.token
}
