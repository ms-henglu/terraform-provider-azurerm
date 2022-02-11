package backupinstances

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

type CurrentProtectionState string

const (
	CurrentProtectionStateBackupSchedulesSuspended    CurrentProtectionState = "BackupSchedulesSuspended"
	CurrentProtectionStateConfiguringProtection       CurrentProtectionState = "ConfiguringProtection"
	CurrentProtectionStateConfiguringProtectionFailed CurrentProtectionState = "ConfiguringProtectionFailed"
	CurrentProtectionStateInvalid                     CurrentProtectionState = "Invalid"
	CurrentProtectionStateNotProtected                CurrentProtectionState = "NotProtected"
	CurrentProtectionStateProtectionConfigured        CurrentProtectionState = "ProtectionConfigured"
	CurrentProtectionStateProtectionError             CurrentProtectionState = "ProtectionError"
	CurrentProtectionStateProtectionStopped           CurrentProtectionState = "ProtectionStopped"
	CurrentProtectionStateRetentionSchedulesSuspended CurrentProtectionState = "RetentionSchedulesSuspended"
	CurrentProtectionStateSoftDeleted                 CurrentProtectionState = "SoftDeleted"
	CurrentProtectionStateSoftDeleting                CurrentProtectionState = "SoftDeleting"
	CurrentProtectionStateUpdatingProtection          CurrentProtectionState = "UpdatingProtection"
)

func PossibleValuesForCurrentProtectionState() []string {
	return []string{
		string(CurrentProtectionStateBackupSchedulesSuspended),
		string(CurrentProtectionStateConfiguringProtection),
		string(CurrentProtectionStateConfiguringProtectionFailed),
		string(CurrentProtectionStateInvalid),
		string(CurrentProtectionStateNotProtected),
		string(CurrentProtectionStateProtectionConfigured),
		string(CurrentProtectionStateProtectionError),
		string(CurrentProtectionStateProtectionStopped),
		string(CurrentProtectionStateRetentionSchedulesSuspended),
		string(CurrentProtectionStateSoftDeleted),
		string(CurrentProtectionStateSoftDeleting),
		string(CurrentProtectionStateUpdatingProtection),
	}
}

func parseCurrentProtectionState(input string) (*CurrentProtectionState, error) {
	vals := map[string]CurrentProtectionState{
		"backupschedulessuspended":    CurrentProtectionStateBackupSchedulesSuspended,
		"configuringprotection":       CurrentProtectionStateConfiguringProtection,
		"configuringprotectionfailed": CurrentProtectionStateConfiguringProtectionFailed,
		"invalid":                     CurrentProtectionStateInvalid,
		"notprotected":                CurrentProtectionStateNotProtected,
		"protectionconfigured":        CurrentProtectionStateProtectionConfigured,
		"protectionerror":             CurrentProtectionStateProtectionError,
		"protectionstopped":           CurrentProtectionStateProtectionStopped,
		"retentionschedulessuspended": CurrentProtectionStateRetentionSchedulesSuspended,
		"softdeleted":                 CurrentProtectionStateSoftDeleted,
		"softdeleting":                CurrentProtectionStateSoftDeleting,
		"updatingprotection":          CurrentProtectionStateUpdatingProtection,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := CurrentProtectionState(input)
	return &out, nil
}

type DataStoreTypes string

const (
	DataStoreTypesArchiveStore     DataStoreTypes = "ArchiveStore"
	DataStoreTypesOperationalStore DataStoreTypes = "OperationalStore"
	DataStoreTypesVaultStore       DataStoreTypes = "VaultStore"
)

func PossibleValuesForDataStoreTypes() []string {
	return []string{
		string(DataStoreTypesArchiveStore),
		string(DataStoreTypesOperationalStore),
		string(DataStoreTypesVaultStore),
	}
}

func parseDataStoreTypes(input string) (*DataStoreTypes, error) {
	vals := map[string]DataStoreTypes{
		"archivestore":     DataStoreTypesArchiveStore,
		"operationalstore": DataStoreTypesOperationalStore,
		"vaultstore":       DataStoreTypesVaultStore,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := DataStoreTypes(input)
	return &out, nil
}

type RecoveryOption string

const (
	RecoveryOptionFailIfExists RecoveryOption = "FailIfExists"
)

func PossibleValuesForRecoveryOption() []string {
	return []string{
		string(RecoveryOptionFailIfExists),
	}
}

func parseRecoveryOption(input string) (*RecoveryOption, error) {
	vals := map[string]RecoveryOption{
		"failifexists": RecoveryOptionFailIfExists,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := RecoveryOption(input)
	return &out, nil
}

type RehydrationPriority string

const (
	RehydrationPriorityHigh     RehydrationPriority = "High"
	RehydrationPriorityInvalid  RehydrationPriority = "Invalid"
	RehydrationPriorityStandard RehydrationPriority = "Standard"
)

func PossibleValuesForRehydrationPriority() []string {
	return []string{
		string(RehydrationPriorityHigh),
		string(RehydrationPriorityInvalid),
		string(RehydrationPriorityStandard),
	}
}

func parseRehydrationPriority(input string) (*RehydrationPriority, error) {
	vals := map[string]RehydrationPriority{
		"high":     RehydrationPriorityHigh,
		"invalid":  RehydrationPriorityInvalid,
		"standard": RehydrationPriorityStandard,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := RehydrationPriority(input)
	return &out, nil
}

type RestoreTargetLocationType string

const (
	RestoreTargetLocationTypeAzureBlobs RestoreTargetLocationType = "AzureBlobs"
	RestoreTargetLocationTypeAzureFiles RestoreTargetLocationType = "AzureFiles"
	RestoreTargetLocationTypeInvalid    RestoreTargetLocationType = "Invalid"
)

func PossibleValuesForRestoreTargetLocationType() []string {
	return []string{
		string(RestoreTargetLocationTypeAzureBlobs),
		string(RestoreTargetLocationTypeAzureFiles),
		string(RestoreTargetLocationTypeInvalid),
	}
}

func parseRestoreTargetLocationType(input string) (*RestoreTargetLocationType, error) {
	vals := map[string]RestoreTargetLocationType{
		"azureblobs": RestoreTargetLocationTypeAzureBlobs,
		"azurefiles": RestoreTargetLocationTypeAzureFiles,
		"invalid":    RestoreTargetLocationTypeInvalid,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := RestoreTargetLocationType(input)
	return &out, nil
}

type SecretStoreType string

const (
	SecretStoreTypeAzureKeyVault SecretStoreType = "AzureKeyVault"
	SecretStoreTypeInvalid       SecretStoreType = "Invalid"
)

func PossibleValuesForSecretStoreType() []string {
	return []string{
		string(SecretStoreTypeAzureKeyVault),
		string(SecretStoreTypeInvalid),
	}
}

func parseSecretStoreType(input string) (*SecretStoreType, error) {
	vals := map[string]SecretStoreType{
		"azurekeyvault": SecretStoreTypeAzureKeyVault,
		"invalid":       SecretStoreTypeInvalid,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := SecretStoreType(input)
	return &out, nil
}

type SourceDataStoreType string

const (
	SourceDataStoreTypeArchiveStore  SourceDataStoreType = "ArchiveStore"
	SourceDataStoreTypeSnapshotStore SourceDataStoreType = "SnapshotStore"
	SourceDataStoreTypeVaultStore    SourceDataStoreType = "VaultStore"
)

func PossibleValuesForSourceDataStoreType() []string {
	return []string{
		string(SourceDataStoreTypeArchiveStore),
		string(SourceDataStoreTypeSnapshotStore),
		string(SourceDataStoreTypeVaultStore),
	}
}

func parseSourceDataStoreType(input string) (*SourceDataStoreType, error) {
	vals := map[string]SourceDataStoreType{
		"archivestore":  SourceDataStoreTypeArchiveStore,
		"snapshotstore": SourceDataStoreTypeSnapshotStore,
		"vaultstore":    SourceDataStoreTypeVaultStore,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := SourceDataStoreType(input)
	return &out, nil
}

type Status string

const (
	StatusConfiguringProtection       Status = "ConfiguringProtection"
	StatusConfiguringProtectionFailed Status = "ConfiguringProtectionFailed"
	StatusProtectionConfigured        Status = "ProtectionConfigured"
	StatusProtectionStopped           Status = "ProtectionStopped"
	StatusSoftDeleted                 Status = "SoftDeleted"
	StatusSoftDeleting                Status = "SoftDeleting"
)

func PossibleValuesForStatus() []string {
	return []string{
		string(StatusConfiguringProtection),
		string(StatusConfiguringProtectionFailed),
		string(StatusProtectionConfigured),
		string(StatusProtectionStopped),
		string(StatusSoftDeleted),
		string(StatusSoftDeleting),
	}
}

func parseStatus(input string) (*Status, error) {
	vals := map[string]Status{
		"configuringprotection":       StatusConfiguringProtection,
		"configuringprotectionfailed": StatusConfiguringProtectionFailed,
		"protectionconfigured":        StatusProtectionConfigured,
		"protectionstopped":           StatusProtectionStopped,
		"softdeleted":                 StatusSoftDeleted,
		"softdeleting":                StatusSoftDeleting,
	}
	if v, ok := vals[strings.ToLower(input)]; ok {
		return &v, nil
	}

	// otherwise presume it's an undefined value and best-effort it
	out := Status(input)
	return &out, nil
}
