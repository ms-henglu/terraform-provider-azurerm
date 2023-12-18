



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231218072308761875"
  location = "West Europe"
}

locals {
  config_content = base64encode(<<-EOT
http {
    server {
        listen 80;
        location / {
            auth_basic "Protected Area";
            auth_basic_user_file /opt/.htpasswd;
            default_type text/html;
            return 200 '<!doctype html><html lang="en"><head></head><body>
                <div>this one will be updated</div>
                <div>at 10:38 am</div>
            </body></html>';
        }
        include site/*.conf;
    }
}
EOT
  )

  protected_content = base64encode(<<-EOT
user:$apr1$VeUA5kt.$IjjRk//8miRxDsZvD4daF1
EOT
  )

  sub_config_content = base64encode(<<-EOT
location /bbb {
	default_type text/html;
	return 200 '<!doctype html><html lang="en"><head></head><body>
		<div>this one will be updated</div>
		<div>at 10:38 am</div>
	</body></html>';
}
EOT
  )
}

resource "azurerm_public_ip" "test" {
  name                = "acctest231218072308761875"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet231218072308761875"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "accsubnet231218072308761875"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "delegation"

    service_delegation {
      name = "NGINX.NGINXPLUS/nginxDeployments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_nginx_deployment" "test" {
  name                = "acctest-231218072308761875"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "standard_Monthly"
  location            = azurerm_resource_group.test.location

  //message: "Conflict managed resource group name: tenant: -91a, subscription xxx, resource group example."
  managed_resource_group   = "accmr231218072308761875"
  diagnose_support_enabled = true

  frontend_public {
    ip_address = [azurerm_public_ip.test.id]
  }

  network_interface {
    subnet_id = azurerm_subnet.test.id
  }
  tags = {
    foo = "bar"
  }
}


resource "azurerm_nginx_configuration" "test" {
  nginx_deployment_id = azurerm_nginx_deployment.test.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content      = local.config_content
    virtual_path = "/etc/nginx/nginx.conf"
  }

  protected_file {
    content      = local.protected_content
    virtual_path = "/opt/.htpasswd"
  }
}
