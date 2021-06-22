package cognitive_test

import (
    "context"
    "fmt"
    "testing"

    "github.com/hashicorp/terraform-plugin-sdk/v2/helper/resource"
    "github.com/hashicorp/terraform-plugin-sdk/v2/terraform"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/acceptance/check"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/cognitive/parse"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

type CognitivePrivateEndpointConnectionResource struct{}

func TestAccCognitivePrivateEndpointConnection_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_cognitive_private_endpoint_connection", "test")
	r := CognitivePrivateEndpointConnectionResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccCognitivePrivateEndpointConnection_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_cognitive_private_endpoint_connection", "test")
	r := CognitivePrivateEndpointConnectionResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func TestAccCognitivePrivateEndpointConnection_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_cognitive_private_endpoint_connection", "test")
	r := CognitivePrivateEndpointConnectionResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccCognitivePrivateEndpointConnection_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_cognitive_private_endpoint_connection", "test")
	r := CognitivePrivateEndpointConnectionResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccCognitivePrivateEndpointConnection_updatePrivateLinkServiceConnectionState(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_cognitive_private_endpoint_connection", "test")
	r := CognitivePrivateEndpointConnectionResource{}
	data.ResourceTest(t, r, []resource.TestStep{
		{
			Config: r.complete(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.updatePrivateLinkServiceConnectionState(data),
			Check: resource.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func (r CognitivePrivateEndpointConnectionResource) Exists(ctx context.Context, client *clients.Client, state *terraform.InstanceState) (*bool, error) {
	id, err := parse.PrivateEndpointConnectionID(state.ID)
	if err != nil {
		return nil, err
	}
	resp, err := client.Cognitive.PrivateEndpointConnectionsClient.Get(ctx, id.ResourceGroup, id.AccountName, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			return utils.Bool(false), nil
		}
		return nil, fmt.Errorf("retrieving Cognitive PrivateEndpointConnection %q (Resource Group %q / accountName %q): %+v", id.Name, id.ResourceGroup, id.AccountName, err)
	}
	return utils.Bool(true), nil
}

func (r CognitivePrivateEndpointConnectionResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-Cognitive-%d"
  location = "%s"
}

resource "azurerm_cognitive_account" "test" {
  name = "acctest-ca-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}
`, data.RandomInteger, data.Locations.Primary, data.RandomInteger)
}

func (r CognitivePrivateEndpointConnectionResource) basic(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_cognitive_private_endpoint_connection" "test" {
  name = "acctest-cpec-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
  account_name = azurerm_cognitive_account.test.name
}
`, template, data.RandomInteger)
}

func (r CognitivePrivateEndpointConnectionResource) requiresImport(data acceptance.TestData) string {
	config := r.basic(data)
	return fmt.Sprintf(`
%s

resource "azurerm_cognitive_private_endpoint_connection" "import" {
  name = azurerm_cognitive_private_endpoint_connection.test.name
  resource_group_name = azurerm_cognitive_private_endpoint_connection.test.resource_group_name
  location = azurerm_cognitive_private_endpoint_connection.test.location
  account_name = azurerm_cognitive_account.test.account_name
}
`, config)
}

func (r CognitivePrivateEndpointConnectionResource) complete(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_cognitive_private_endpoint_connection" "test" {
  name = "acctest-cpec-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
  account_name = azurerm_cognitive_account.test.name
  group_ids = []
  private_link_service_connection_state {
    actions_required = ""
    description = "Auto-Approved"
  }
}
`, template, data.RandomInteger)
}

func (r CognitivePrivateEndpointConnectionResource) updatePrivateLinkServiceConnectionState(data acceptance.TestData) string {
	template := r.template(data)
	return fmt.Sprintf(`
%s

resource "azurerm_cognitive_private_endpoint_connection" "test" {
  name = "acctest-cpec-%d"
  resource_group_name = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
  account_name = azurerm_cognitive_account.test.name
  group_ids = []
  private_link_service_connection_state {
    actions_required = ""
    description = "Auto-Approved"
  }
}
`, template, data.RandomInteger)
}
