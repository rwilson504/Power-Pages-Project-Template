param(
    [bool]$IncludeGuids = $true
)
# Output is written to the Documentation folder


# Simple YAML parser for flat key-value pairs
function Parse-YamlSimple {
    param([string[]]$Lines)
    $result = @{}
    foreach ($line in $Lines) {
        if ($line -match '^[ \t]*#') { continue } # skip comments
        if ($line -match '^[ \t]*$') { continue } # skip empty lines
        if ($line -match '^(.*?)\s*:\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $result[$key] = $value
        }
    }
    return $result
}

$sitesRoot = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'sites'
$docsRoot = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'docs'

# Ensure Documentation folder exists
if (!(Test-Path $docsRoot)) {
    New-Item -ItemType Directory -Path $docsRoot | Out-Null
}

# Get all site folders
$siteFolders = Get-ChildItem -Path $sitesRoot -Directory

foreach ($site in $siteFolders) {
    $siteName = $site.Name
    $sitePath = $site.FullName
    $mdPath = Join-Path $docsRoot "$siteName-Security.md"
    # Read website.yml for site display name and id
    $websiteFile = Join-Path $sitePath 'website.yml'
    $siteDisplayName = $siteName
    $siteId = ''

    if (Test-Path $websiteFile) {
        $website = Parse-YamlSimple (Get-Content $websiteFile)
        if ($website.ContainsKey('adx_name')) { $siteDisplayName = $website['adx_name'] }
        if ($website.ContainsKey('adx_websiteid')) { $siteId = $website['adx_websiteid'] }
    }

    $mdContent = "# Power Pages Documentation`n"
    $mdContent += "Site Name: $siteDisplayName`n"
    if ($IncludeGuids -and $siteId) {
        $mdContent += "Site Id: $siteId`n"
    }
    $mdContent += "`n"
    $siteSettingFile = Join-Path $sitePath 'sitesetting.yml'
    $siteSettingsSection = ""
    # Build Web Page ID to Name lookup (case-insensitive, trimmed, all .yml files, robust for any .yml)
    $webPageNameLookup = @{}
    if ($sitePath) {
        $webPagesFolder = Join-Path $sitePath 'web-pages'
        if (Test-Path $webPagesFolder) {
            $webPageFiles = Get-ChildItem -Path $webPagesFolder -Recurse -Filter '*.yml'
            foreach ($webPageFile in $webPageFiles) {
                $webPageYaml = Get-Content $webPageFile.FullName -Raw | ConvertFrom-Yaml
                # Handle both single-object and array-of-objects YAML
                if ($null -ne $webPageYaml) {
                    if ($webPageYaml -is [System.Collections.IEnumerable] -and -not ($webPageYaml -is [string])) {
                        foreach ($webPage in $webPageYaml) {
                            if ($webPage -and $webPage.adx_webpageid) {
                                $name = $null
                                if ($webPage.ContainsKey('adx_name') -and $webPage.adx_name) {
                                    $name = $webPage.adx_name
                                } elseif ($webPage.ContainsKey('adx_title') -and $webPage.adx_title) {
                                    $name = $webPage.adx_title
                                } else {
                                    $name = $webPage.adx_webpageid
                                }
                                $key = ($webPage.adx_webpageid).ToString().Trim().ToLower()
                                $webPageNameLookup[$key] = $name
                            }
                        }
                    } else {
                        $webPage = $webPageYaml
                        if ($webPage -and $webPage.adx_webpageid) {
                            $name = $null
                            if ($webPage.ContainsKey('adx_name') -and $webPage.adx_name) {
                                $name = $webPage.adx_name
                            } elseif ($webPage.ContainsKey('adx_title') -and $webPage.adx_title) {
                                $name = $webPage.adx_title
                            } else {
                                $name = $webPage.adx_webpageid
                            }
                            $key = ($webPage.adx_webpageid).ToString().Trim().ToLower()
                            $webPageNameLookup[$key] = $name
                        }
                    }
                }
            }
        }
    }
    $siteName = $site.Name
    $sitePath = $site.FullName
    $mdPath = Join-Path $docsRoot "$siteName-Security.md"

    $webRoleFile = Join-Path $sitePath 'webrole.yml'
    $webPageRuleFile = Join-Path $sitePath 'webpagerule.yml'
    $tablePermFolder = Join-Path $sitePath 'table-permissions'

    # Web Roles
    $webRoleNameLookup = @{}
    if (Test-Path $webRoleFile) {
        $webRoles = (Get-Content $webRoleFile | ConvertFrom-Yaml)
        foreach ($role in ($webRoles | Sort-Object { $_.adx_name.ToLower() })) {
            $webRoleNameLookup[$role.adx_webroleid] = $role.adx_name
        }
        $mdContent += "## Web Roles`n| Name | Description | Authenticated | Anonymous | ID |`n|---|---|---|---|---|`n"
        foreach ($role in ($webRoles | Sort-Object { $_.adx_name.ToLower() })) {
            $mdContent += "| $($role.adx_name) | $($role.adx_description) | $($role.adx_authenticatedusersrole) | $($role.adx_anonymoususersrole) | $($role.adx_webroleid) |`n"
        }
        $mdContent += "`n"
    }

    # Page Permissions
    if (Test-Path $webPageRuleFile) {
        $pagePerms = (Get-Content $webPageRuleFile | ConvertFrom-Yaml)
        $mdContent += "## Page Permissions`n| Name | Right | Scope | Web Roles | Page Name | Rule ID |`n|---|---|---|---|---|---|`n"
        foreach ($perm in ($pagePerms | Sort-Object { $_.adx_name.ToLower() })) {
            $roleNames = @()
            if ($perm.adx_webpageaccesscontrolrule_webrole) {
                foreach ($roleId in $perm.adx_webpageaccesscontrolrule_webrole) {
                    if ($webRoleNameLookup.ContainsKey($roleId)) {
                        $roleNames += $webRoleNameLookup[$roleId]
                    } else {
                        $roleNames += $roleId
                    }
                }
            }
            $roles = $roleNames -join ', '
            $pageName = $perm.adx_webpageid
            if ($perm.adx_webpageid) {
                $lookupKey = ($perm.adx_webpageid).ToString().Trim().ToLower()
                if ($webPageNameLookup.ContainsKey($lookupKey)) {
                    $pageName = $webPageNameLookup[$lookupKey]
                }
            }
            $mdContent += "| $($perm.adx_name) | $($perm.adx_right) | $($perm.adx_scope) | $roles | $pageName | $($perm.adx_webpageaccesscontrolruleid) |`n"
        }
        $mdContent += "`n"
    }

    # Table Permissions
    if (Test-Path $tablePermFolder) {
        $tablePermFiles = Get-ChildItem -Path $tablePermFolder -Filter '*.tablepermission.yml'
        $tablePerms = @()
        $permLookup = @{}
        foreach ($permFile in $tablePermFiles) {
            $perm = Get-Content $permFile.FullName | ConvertFrom-Yaml
            $tablePerms += $perm
            $permLookup[$perm.adx_entitypermissionid] = $perm
        }

        # Build parent-child relationships
        $childrenLookup = @{}
        foreach ($perm in $tablePerms) {
            if ($perm.adx_parententitypermission) {
                if (-not $childrenLookup.ContainsKey($perm.adx_parententitypermission)) {
                    $childrenLookup[$perm.adx_parententitypermission] = @()
                }
                $childrenLookup[$perm.adx_parententitypermission] += $perm
            }
        }

        # Recursive function to output permissions in parent-child order
        function Write-PermissionRow {
            param(
                $perm,
                $permLookup,
                $childrenLookup,
                [System.Text.StringBuilder]$mdTableContent,
                $depth = 0
            )
            $roleNames = @()
            if ($perm.adx_entitypermission_webrole) {
                foreach ($roleId in $perm.adx_entitypermission_webrole) {
                    if ($webRoleNameLookup.ContainsKey($roleId)) {
                        $roleNames += $webRoleNameLookup[$roleId]
                    } else {
                        $roleNames += $roleId
                    }
                }
            }
            $roles = $roleNames -join ', '
            # Scope mapping
            $scopeMap = @{
                '756150000' = 'Global'
                '756150001' = 'Contact'
                '756150002' = 'Account'
                '756150003' = 'Parent'
                '756150004' = 'Self'
            }
            $scopeValue = $perm.adx_scope
            $scopeDisplay = $scopeValue
            if ($scopeMap.ContainsKey($scopeValue.ToString())) {
                $scopeDisplay = $scopeMap[$scopeValue.ToString()]
            }
            $nbsp = '&nbsp;' * 4 * $depth
            $arrow = [char]0x21B3
            $displayName = if ($depth -gt 0) { "$nbsp$arrow $($perm.adx_entityname)" } else { "$nbsp$($perm.adx_entityname)" }
            [void]$mdTableContent.AppendLine("| $displayName | $($perm.adx_entitylogicalname) | $($perm.adx_read) | $($perm.adx_write) | $($perm.adx_create) | $($perm.adx_delete) | $($perm.adx_append) | $($perm.adx_appendto) | $scopeDisplay | $roles | $($perm.adx_entitypermissionid) |")
            
            if ($childrenLookup.ContainsKey($perm.adx_entitypermissionid)) {
                $children = $childrenLookup[$perm.adx_entitypermissionid] | Sort-Object adx_entityname
                foreach ($child in $children) {
                    Write-PermissionRow -perm $child -permLookup $permLookup -childrenLookup $childrenLookup -mdTableContent $mdTableContent -depth ($depth + 1)
                }
            }
        }

        # Use StringBuilder for Markdown table content
        $mdTableContent = New-Object -TypeName System.Text.StringBuilder
        [void]$mdTableContent.AppendLine("## Table Permissions")
        [void]$mdTableContent.AppendLine("| Name | Entity | Read | Write | Create | Delete | Append | AppendTo | Scope | Web Roles | Permission ID |")
        [void]$mdTableContent.AppendLine("|---|---|---|---|---|---|---|---|---|---|---|")

        $roots = $tablePerms | Where-Object { -not $_.adx_parententitypermission } | Sort-Object { $_.adx_entityname.ToLower() }
        foreach ($root in $roots) {
            Write-PermissionRow -perm $root -permLookup $permLookup -childrenLookup $childrenLookup -mdTableContent $mdTableContent -depth 0
        }

        $mdContent += $mdTableContent.ToString()
        $mdContent += "`n"
    }

    # Site Settings (append at end)
    if (Test-Path $siteSettingFile) {
        $siteSettingsLines = Get-Content $siteSettingFile
        $siteSettings = @()
        $current = @{}
        foreach ($line in $siteSettingsLines) {
            if ($line -match '^[ \t]*-[ \t]*$') {
                if ($current.Count -gt 0) { $siteSettings += ,$current; $current = @{} }
            } elseif ($line -match '^(.*?)\s*:\s*(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $current[$key] = $value
            }
        }
        if ($current.Count -gt 0) { $siteSettings += ,$current }
        $siteSettingsSection += "## Site Settings`n| Name | Value | Description | Setting ID |`n|---|---|---|---|`n"
        foreach ($setting in ($siteSettings | Sort-Object { $_['adx_name'].ToLower() })) {
            $name = $setting['adx_name']
            $value = $setting['adx_value']
            $desc = $setting['adx_description']
            $id = $setting['adx_sitesettingid']
            # Escape pipe and replace newlines for Markdown
            if ($value) {
                $value = $value -replace '\|', '&#124;'
                $value = $value -replace "`r?`n", '<br>'
            }
            if ($desc) {
                $desc = $desc -replace '\|', '&#124;'
                $desc = $desc -replace "`r?`n", '<br>'
            }
            $siteSettingsSection += "| $name | $value | $desc | $id |`n"
        }
        $siteSettingsSection += "`n"
    }

    # Write to Markdown file
    Set-Content -Path $mdPath -Value ($mdContent + $siteSettingsSection) -Encoding UTF8
}
