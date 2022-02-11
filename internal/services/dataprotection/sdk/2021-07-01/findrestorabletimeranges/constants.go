package findrestorabletimeranges

import "strings"

type CreatedByType string

const (
	CreatedByTypeApplication     CreatedByType = "Application"
	CreatedByTypeKey             CreatedByType = "Key"
	CreatedByTypeManagedIdentity CreatedByType = "ManagedIdentity"
	CreatedByTypeUser            CreatedByType = "User"
)

func PossibleValuesForCreatedByType() []string {
	return []string{
		string(CreatedByTypeApplication),
		string(CreatedByTypeKey),
		string(CreatedByTypeManagedIdentity),
		string(CreatedByTypeUser),
	}
}

func parseCreatedByType(input string) (*CreatedByType, error) {
	vals := map[string]CreatedByType{
		"application":     CreatedByTypeApplication,
		"key":             CreatedByTypeKey,
		"managedidentity": CreatedByTypeManagedIdentity,
		"user":            CreatedByTypeUser,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := CreatedByType(input)
	return &out, nil
}

type RestoreSourceDataStoreType string

const (
	RestoreSourceDataStoreTypeArchiveStore     RestoreSourceDataStoreType = "ArchiveStore"
	RestoreSourceDataStoreTypeOperationalStore RestoreSourceDataStoreType = "OperationalStore"
	RestoreSourceDataStoreTypeVaultStore       RestoreSourceDataStoreType = "VaultStore"
)

func PossibleValuesForRestoreSourceDataStoreType() []string {
	return []string{
		string(RestoreSourceDataStoreTypeArchiveStore),
		string(RestoreSourceDataStoreTypeOperationalStore),
		string(RestoreSourceDataStoreTypeVaultStore),
	}
}

func parseRestoreSourceDataStoreType(input string) (*RestoreSourceDataStoreType, error) {
	vals := map[string]RestoreSourceDataStoreType{
		"archivestore":     RestoreSourceDataStoreTypeArchiveStore,
		"operationalstore": RestoreSourceDataStoreTypeOperationalStore,
		"vaultstore":       RestoreSourceDataStoreTypeVaultStore,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := RestoreSourceDataStoreType(input)
	return &out, nil
}
