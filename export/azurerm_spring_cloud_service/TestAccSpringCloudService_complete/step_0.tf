
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230707004806160541"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-230707004806160541"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230707004806160541"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  config_server_git_setting {
    uri          = "git@bitbucket.org:Azure-Samples/piggymetrics.git"
    label        = "config"
    search_paths = ["dir1", "dir4"]

    ssh_auth {
      private_key                      = file("testdata/private_key")
      host_key                         = file("testdata/host_key")
      host_key_algorithm               = "ssh-rsa"
      strict_host_key_checking_enabled = false
    }

    repository {
      name         = "repo1"
      uri          = "https://github.com/Azure-Samples/piggymetrics"
      label        = "config"
      search_paths = ["dir1", "dir2"]
      http_basic_auth {
        username = "username"
        password = "password"
      }
    }

    repository {
      name         = "repo2"
      uri          = "https://github.com/Azure-Samples/piggymetrics"
      label        = "config"
      search_paths = ["dir1", "dir2"]
    }
  }

  trace {
    connection_string = azurerm_application_insights.test.connection_string
    sample_rate       = 20
  }

  tags = {
    Env     = "Test"
    version = "1"
  }
}
