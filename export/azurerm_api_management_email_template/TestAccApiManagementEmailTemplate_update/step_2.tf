

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060507031377"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922060507031377"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}


resource "azurerm_api_management_email_template" "test" {
  template_name       = "ConfirmSignUpIdentityDefault"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  subject             = "Please confirm your new customized $OrganizationName API account with this customized and updated email"
  body                = <<EOF
<!DOCTYPE html >
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Customized Letter Title</title>
  </head>
  <body>
    <table width="100%">
      <tr>
        <td>
          <p style="font-size:12pt;font-family:'Segoe UI'">Dear $DevFirstName $DevLastName,</p>
          <p style="font-size:12pt;font-family:'Segoe UI'"></p>
          <p style="font-size:12pt;font-family:'Segoe UI'">Thank you for joining the $OrganizationName API program! We host a growing number of cool APIs and strive to provide an awesome experience for API developers.</p>
          <p style="font-size:12pt;font-family:'Segoe UI'">This email is automatically created using a customized template witch is stored configuration as code.</p>
        </td>
      </tr>
    </table>
  </body>
</html>
EOF
}
