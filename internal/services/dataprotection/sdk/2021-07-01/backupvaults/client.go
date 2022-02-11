package backupvaults

import "github.com/Azure/go-autorest/autorest"

type BackupVaultsClient struct {
	Client  autorest.Client
	baseUri string
}

func NewBackupVaultsClientWithBaseURI(endpoint string) BackupVaultsClient {
	return BackupVaultsClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
