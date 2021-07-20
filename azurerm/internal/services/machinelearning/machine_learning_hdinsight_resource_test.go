package machinelearning_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/validate"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/machinelearning/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type MachineLearningHDInsightResource struct{}

var ignores = []string{"credential.0.username", "credential.0.password", "credential.0.public_key", "credential.0.private_key", "credential.#", "credential.0.%"}

func TestAccMachineLearningHDInsight_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
	})
}

func TestAccMachineLearningHDInsight_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.#").HasValue("1"),
				check.That(data.ResourceName).Key("identity.0.type").HasValue("SystemAssigned"),
				check.That(data.ResourceName).Key("identity.0.principal_id").Exists(),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(ignores...),
	})
}

func TestAccMachineLearningHDInsight_sshKeys(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.sshKeys(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
	})
}

func TestAccMachineLearningHDInsight_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
	})
}

func TestAccMachineLearningHDInsight_identity(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
		{
			Config: r.identitySystemAssignedUserAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.0.principal_id").MatchesRegex(validate.UUIDRegExp),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(ignores...),
		{
			Config: r.identityUserAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(ignores...),
		{
			Config: r.identitySystemAssigned(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
				check.That(data.ResourceName).Key("identity.0.principal_id").MatchesRegex(validate.UUIDRegExp),
				check.That(data.ResourceName).Key("identity.0.tenant_id").Exists(),
			),
		},
		data.ImportStep(ignores...),
	})
}

func TestAccMachineLearningHDInsight_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_machine_learning_hdinsight", "test")
	r := MachineLearningHDInsightResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func (r MachineLearningHDInsightResource) Exists(ctx context.Context, client *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	computeClusterClient := client.MachineLearning.MachineLearningComputeClient
	id, err := parse.ComputeID(state.ID)

	if err != nil {
		return nil, err
	}

	computeResource, err := computeClusterClient.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(computeResource.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Machine Learning Compute %q: %+v", state.ID, err)
	}
	return utils.Bool(computeResource.Properties != nil), nil
}

func (r MachineLearningHDInsightResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }

  identity {
    type = "SystemAssigned"
  }
  description = "test"
  tags = {
    "Key" = "value"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) sshKeys(data acceptance.TestData) string {
	template := r.templateSSHKeys(data)
	return fmt.Sprintf(`
%s

resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username    = "acctestusrvm"
    private_key = "-----BEGIN OPENSSH PRIVATE KEY-----b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcnNhAAAAAwEAAQAAAQEA6S/yiFUCbeSiXxqm/SpzzAKtQyx7N3wcFtQyOv73HW2popu/WyNqvBA18c5RqSkQRSDTOxK4ZXKZwGaVR/uSfBiaye0EuNeFI5fDKTOyQI/kwcd5pzwCERMZkGvuXE55ljJLA21i+HvIgPbVjbwILVBM9vOjiai8oEJAQuD4cNokM1a04G4xr4oxtg3pux99EMukrabmYYzgfx7MVcvheJxZsbM4Q5Uq4wUEdJ1WEKgf/4j3iyqXsDaPdurI/IkLgcSRVuA4AWTe1BQ5SoOOU+/X4DajL9uRfOPBQxNnFkS0JhZR9lEEuw/fbhwj2leC84Aef1RWNOjZ94wRlzIQCwAAA9B0mcSUdJnElAAAAAdzc2gtcnNhAAABAQDpL/KIVQJt5KJfGqb9KnPMAq1DLHs3fBwW1DI6/vcdbamim79bI2q8EDXxzlGpKRBFINM7ErhlcpnAZpVH+5J8GJrJ7QS414Ujl8MpM7JAj+TBx3mnPAIRExmQa+5cTnmWMksDbWL4e8iA9tWNvAgtUEz286OJqLygQkBC4Phw2iQzVrTgbjGvijG2Dem7H30Qy6StpuZhjOB/HsxVy+F4nFmxszhDlSrjBQR0nVYQqB//iPeLKpewNo926sj8iQuBxJFW4DgBZN7UFDlKg45T79fgNqMv25F848FDE2cWRLQmFlH2UQS7D99uHCPaV4LzgB5/VFY06Nn3jBGXMhALAAAAAwEAAQAAAQEAvWFEXrZzn55ExGpX3lng63ntDxYMB/bStTOmi8VQGmValIZa9YChCZU8ymIebfy8ivfqtRoyCan19o0ZhflpcUFmTMIiyJ+4MDzrsgWbKdXzGfGP+mLA5u8VHvaZAfx1wKadx23KKDYXk61jqJViKrMBnromQgF5F8pWeDpPaw4h3Zo8N7V4mbPGK3iR2Cdd223bnkrc3Pt38TtXsvPsz8235IHm76oTnO2h3oiteEHwosRSvs4i4xKQXuqXhQenI4WHzfg67najVB5Qn0ekHikQv9CT16AMfH+OvQjkzEskpd30ycGCbRGEwONmx/DUOHUrT3B68L407v2nXQ4CIQAAAIBMHiPwQFEUia4dWQkQARqCSWJNZBNYcfAXTrb6uq/D1qXbDQbKRX4VgLPVhL15JuZ2rYkJdWwI/Qo5Hqt8cFTBvGr7n4HR3ECggWdMFBaAbcvA6sJMxvwZDHgANvkp91Cc8+t6OwTP3cei1P55LJVOPs7EcXnq0mglb7QHmyc6UwAAAIEA93vy9qEGj2blfM2Tjxh6RH9C4+N9Ovj66U5gy3sOeB0yC52LaPRJEjdaIOcY+6lVxVroKxZqr+D7gtmBvIIQ5rAflqc9jBwg++wkGXwK4gZGlNn92U76VB7m+rPDybbI4c1JMYdJYS3lS6TBzNTo5j1CSpsKQBhlPWfnk5iWtNEAAACBAPE2DyoKKYOmRfvSerQhzhliB4sPHQJusQDefSw7ewh19TP3JNq+ojzucL1fPpA4beU0T4GbFYVZAlhCuOmyKmXcUGmMgm/WYsVYqVXWLOSqSqnn5kOjBGEdkyMz5zDNGAOwtN9oMZf3e1MWnwBAVtYxKvDbqp8WdnQenqf9dJ4bAAAAGGhlbmdsdUBjbi1oZW5nbHUtZGVza3RvcAEC-----END OPENSSH PRIVATE KEY-----"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) requiresImport(data acceptance.TestData) string {
	template := r.basic(data)
	return fmt.Sprintf(`
%s
resource "azurerm_machine_learning_hdinsight" "import" {
  name                          = azurerm_machine_learning_hdinsight.test.name
  location                      = azurerm_machine_learning_hdinsight.test.location
  machine_learning_workspace_id = azurerm_machine_learning_hdinsight.test.machine_learning_workspace_id
  hdinsight_cluster_id          = azurerm_machine_learning_hdinsight.test.hdinsight_cluster_id
  hdinsight_endpoint            = azurerm_machine_learning_hdinsight.test.hdinsight_endpoint
  hdinsight_ssh_port            = azurerm_machine_learning_hdinsight.test.hdinsight_ssh_port

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }
}

`, template)
}

func (r MachineLearningHDInsightResource) identitySystemAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }

  identity {
    type = "SystemAssigned"
  }
}
`, template, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) identityUserAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
`, template, data.RandomInteger, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) identitySystemAssignedUserAssigned(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s
resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_machine_learning_hdinsight" "test" {
  name                          = "acctest%d"
  location                      = azurerm_resource_group.test.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.test.id
  hdinsight_cluster_id          = azurerm_hdinsight_hadoop_cluster.test.id
  hdinsight_endpoint            = azurerm_hdinsight_hadoop_cluster.test.ssh_endpoint
  hdinsight_ssh_port            = 22

  credential {
    username = "acctestusrvm"
    password = "AccTestvdSC4daf986!"
  }

  identity {
    type = "SystemAssigned,UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
`, template, data.RandomInteger, data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-%d"
  location = "%s"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acc%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acc%d"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestsc%d"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_hadoop_cluster" "test" {
  name                = "acctesthdi%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    hadoop = "3.1"
  }

  gateway {
    username = "acctestusrgw"
    password = "TerrAform123!"
  }

  storage_account {
    storage_container_id = azurerm_storage_container.test.id
    storage_account_key  = azurerm_storage_account.test.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_D3_v2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }

    worker_node {
      vm_size               = "Standard_D4_V2"
      username              = "acctestusrvm"
      password              = "AccTestvdSC4daf986!"
      target_instance_count = 2
    }

    zookeeper_node {
      vm_size  = "Standard_D3_v2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW%d"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}
`, data.RandomInteger, data.Locations.Primary,
		data.RandomIntOfLength(8), data.RandomIntOfLength(16), data.RandomIntOfLength(16),
		data.RandomIntOfLength(16), data.RandomIntOfLength(8), data.RandomIntOfLength(8))
}

func (r MachineLearningHDInsightResource) templateSSHKeys(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpL/KIVQJt5KJfGqb9KnPMAq1DLHs3fBwW1DI6/vcdbamim79bI2q8EDXxzlGpKRBFINM7ErhlcpnAZpVH+5J8GJrJ7QS414Ujl8MpM7JAj+TBx3mnPAIRExmQa+5cTnmWMksDbWL4e8iA9tWNvAgtUEz286OJqLygQkBC4Phw2iQzVrTgbjGvijG2Dem7H30Qy6StpuZhjOB/HsxVy+F4nFmxszhDlSrjBQR0nVYQqB//iPeLKpewNo926sj8iQuBxJFW4DgBZN7UFDlKg45T79fgNqMv25F848FDE2cWRLQmFlH2UQS7D99uHCPaV4LzgB5/VFY06Nn3jBGXMhAL henglu@cn-henglu-desktop"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-ml-%d"
  location = "%s"
  tags = {
    "stage" = "test"
  }
}

resource "azurerm_application_insights" "test" {
  name                = "acctestai-%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_key_vault" "test" {
  name                = "acc%d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled = true
}

resource "azurerm_storage_account" "test" {
  name                     = "acc%d"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestsc%d"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_hadoop_cluster" "test" {
  name                = "acctesthdi%d"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    hadoop = "3.1"
  }

  gateway {
    username = "acctestusrgw"
    password = "TerrAform123!"
  }

  storage_account {
    storage_container_id = azurerm_storage_container.test.id
    storage_account_key  = azurerm_storage_account.test.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_D3_v2"
      username = "acctestusrvm"
      ssh_keys = [var.ssh_key]
    }

    worker_node {
      vm_size               = "Standard_D4_V2"
      username              = "acctestusrvm"
      password              = "AccTestvdSC4daf986!"
      target_instance_count = 2
    }

    zookeeper_node {
      vm_size  = "Standard_D3_v2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}

resource "azurerm_machine_learning_workspace" "test" {
  name                    = "acctest-MLW%d"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  key_vault_id            = azurerm_key_vault.test.id
  storage_account_id      = azurerm_storage_account.test.id

  identity {
    type = "SystemAssigned"
  }
}
`, data.RandomInteger, data.Locations.Primary,
		data.RandomIntOfLength(8), data.RandomIntOfLength(16), data.RandomIntOfLength(16),
		data.RandomIntOfLength(16), data.RandomIntOfLength(8), data.RandomIntOfLength(8))
}
