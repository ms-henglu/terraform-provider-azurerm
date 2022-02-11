package azurebackupjobs

import "fmt"

const defaultApiVersion = "2021-07-01"

func userAgent() string {
	return fmt.Sprintf("pandora/azurebackupjobs/%s", defaultApiVersion)
}
