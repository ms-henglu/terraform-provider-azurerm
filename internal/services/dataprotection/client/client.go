package client

import (
	"github.com/hashicorp/terraform-provider-azurerm/internal/common"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/dataprotection/legacysdk/dataprotection"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/dataprotection/sdk/2021-07-01/backupvaults"
)

type Client struct {
	BackupVaultClient    *backupvaults.BackupVaultsClient
	BackupPolicyClient   *dataprotection.BackupPoliciesClient
	BackupInstanceClient *dataprotection.BackupInstancesClient
}

func NewClient(o *common.ClientOptions) *Client {
	backupVaultClient := backupvaults.NewBackupVaultsClientWithBaseURI(o.ResourceManagerEndpoint)
	o.ConfigureClient(&backupVaultClient.Client, o.ResourceManagerAuthorizer)

	backupPolicyClient := dataprotection.NewBackupPoliciesClientWithBaseURI(o.ResourceManagerEndpoint, o.SubscriptionId)
	o.ConfigureClient(&backupPolicyClient.Client, o.ResourceManagerAuthorizer)

	backupInstanceClient := dataprotection.NewBackupInstancesClientWithBaseURI(o.ResourceManagerEndpoint, o.SubscriptionId)
	o.ConfigureClient(&backupInstanceClient.Client, o.ResourceManagerAuthorizer)

	return &Client{
		BackupVaultClient:    &backupVaultClient,
		BackupPolicyClient:   &backupPolicyClient,
		BackupInstanceClient: &backupInstanceClient,
	}
}
