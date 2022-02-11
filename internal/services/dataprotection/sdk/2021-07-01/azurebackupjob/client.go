package azurebackupjob

import "github.com/Azure/go-autorest/autorest"

type AzureBackupJobClient struct {
	Client  autorest.Client
	baseUri string
}

func NewAzureBackupJobClientWithBaseURI(endpoint string) AzureBackupJobClient {
	return AzureBackupJobClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
