# Robust YAML object list parser for flat objects and multi-line values
param(
    [bool]$IncludeGuids = $true
)
# Output is written to the Documentation folder

# Robust YAML parser for flat key-value pairs and standard YAML lists
function Convert-YamlSimple {
    param([string[]]$Lines)
    $objects = @()
    $current = $null
    foreach ($line in $Lines) {
        if ($line -match '^[ \t]*#') { continue }
        if ($line -match '^[ \t]*$') { continue }

        # Match start of a new object
        if ($line -match '^\s*-\s*(.*)$') {
            if ($current -and $current.Count -gt 0) { $objects += , $current }
            $current = @{}
            $line2 = $matches[1]
            if ($line2 -match '^(.*?)\s*:\s*(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                $current[$key] = $value
            }
            continue
        }

        # Match continuation of current object
        if ($line -match '^(.*?)\s*:\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($null -eq $current) { $current = @{} }
            $current[$key] = $value
        }
    }
    if ($current -and $current.Count -gt 0) { $objects += , $current }

    if ($objects.Count -eq 0) { return $null }
    if ($objects.Count -eq 1) { return $objects[0] }
    return $objects
}

function Convert-YamlObjectList {
    param([string[]]$Lines)

    $objects = @()
    $current = @{}
    $arrayKey = $null

    foreach ($line in $Lines) {
        if ($line -match '^[ \t]*#') { continue }
        if ($line -match '^[ \t]*$') { continue }

        # New item start
        if ($line -match '^[ \t]*-[ \t]*$') {
            if ($current.Count -gt 0) {
                $objects += , $current
                $current = @{}
            }
            $arrayKey = $null
            continue
        }

        # New item with first key inline (e.g., "- key: value")
        if ($line -match '^[ \t]*-\s*(\S.*?)\s*:\s*(.*?)\s*$') {
            if ($current.Count -gt 0) {
                $objects += , $current
                $current = @{}
            }
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $current[$key] = $value
            $arrayKey = $null
            continue
        }

        # Regular key: value
        if ($line -match '^\s*(\S.*?)\s*:\s*(.*?)\s*$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($value -eq '') {
                # Start of array value
                $arrayKey = $key
                $current[$arrayKey] = @()
            }
            else {
                $current[$key] = $value
                $arrayKey = $null
            }
            continue
        }

        # Array entry (e.g. "  - guid1")
        if ($line -match '^\s*-\s*(.*?)\s*$' -and $arrayKey) {
            $current[$arrayKey] += $matches[1].Trim()
            continue
        }
    }

    if ($current.Count -gt 0) {
        $objects += , $current
    }

    return $objects
}

function Convert-YamlFlatWithArrays {
    param([string[]]$Lines)
    $result = @{}
    $currentKey = $null
    foreach ($line in $Lines) {
        if ($line -match '^[ \t]*#') { continue }
        if ($line -match '^[ \t]*$') { continue }
        if ($line -match '^(.*?)\s*:\s*$') {
            # Key with no value, expect array or nested block
            $currentKey = $matches[1].Trim()
            $result[$currentKey] = @()
            continue
        }
        if ($line -match '^- (.*)$' -and $currentKey) {
            # Array item for the last key
            $result[$currentKey] += $matches[1].Trim()
            continue
        }
        if ($line -match '^(.*?)\s*:\s*(.*)$') {
            # Simple key/value
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $result[$key] = $value
            $currentKey = $null
            continue
        }
    }
    return $result
}

function Convert-YamlObjectListWithArrays {
    param([string[]]$Lines)

    $objects = @()
    $current = @{}
    $currentKey = $null
    $inArray = $false

    foreach ($line in $Lines) {
        if ($line -match '^\s*#') { continue }
        if ($line -match '^\s*$') { continue }

        # New object with first key/value (e.g., "- key: value")
        if ($line -match '^\s*-\s*(\S.*?)\s*:\s*(.*?)\s*$') {
            if ($current.Count -gt 0) { $objects += ,$current; $current = @{} }
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $current[$key] = $value
            $currentKey = $null
            $inArray = $false
            continue
        }

        # Standalone new object marker (e.g., just "-")
        if ($line -match '^\s*-\s*$') {
            if ($current.Count -gt 0) { $objects += ,$current; $current = @{} }
            $currentKey = $null
            $inArray = $false
            continue
        }

        # Key with no value (start of array)
        if ($line -match '^\s*(\S.*?)\s*:\s*$') {
            $currentKey = $matches[1].Trim()
            $current[$currentKey] = @()
            $inArray = $true
            continue
        }

        # Array item (must come after a key with no value)
        if ($inArray -and $line -match '^\s*-\s*(.*?)\s*$') {
            $current[$currentKey] += $matches[1].Trim()
            continue
        }

        # Regular key/value pair
        if ($line -match '^\s*(\S.*?)\s*:\s*(.*?)\s*$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $current[$key] = $value
            $currentKey = $null
            $inArray = $false
            continue
        }
    }

    if ($current.Count -gt 0) { $objects += ,$current }

    return $objects
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
        $website = Convert-YamlSimple (Get-Content $websiteFile)
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
                $wegPageContent = Get-Content $webPageFile.FullName
                $webPageYaml = Convert-YamlSimple $wegPageContent
                # Handle both single-object and array-of-objects YAML
                if ($null -ne $webPageYaml) {
                    if ($webPageYaml -is [System.Collections.IEnumerable] -and -not ($webPageYaml -is [string])) {
                        foreach ($webPage in $webPageYaml) {
                            if ($webPage -and $webPage.adx_webpageid) {
                                $name = $null
                                if ($webPage.ContainsKey('adx_name') -and $webPage.adx_name) {
                                    $name = $webPage.adx_name
                                }
                                elseif ($webPage.ContainsKey('adx_title') -and $webPage.adx_title) {
                                    $name = $webPage.adx_title
                                }
                                else {
                                    $name = $webPage.adx_webpageid
                                }
                                $key = ($webPage.adx_webpageid).ToString().Trim().ToLower()
                                $webPageNameLookup[$key] = $name
                            }
                        }
                    }
                    else {
                        $webPage = $webPageYaml
                        if ($webPage -and $webPage.adx_webpageid) {
                            $name = $null
                            if ($webPage.ContainsKey('adx_name') -and $webPage.adx_name) {
                                $name = $webPage.adx_name
                            }
                            elseif ($webPage.ContainsKey('adx_title') -and $webPage.adx_title) {
                                $name = $webPage.adx_title
                            }
                            else {
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
        $webRoleContent = Get-Content $webRoleFile
        $webRoles = Convert-YamlSimple $webRoleContent
        # Write-Host "[DEBUG] webRoles: $($webRoles | ConvertTo-Json -Depth 5)"
        if ($null -ne $webRoles) {
            if ($webRoles -isnot [System.Collections.IEnumerable] -or $webRoles -is [string]) {
                $webRoles = @($webRoles)
            }
            # DEBUG: Output parsed webRoles
            # Write-Host "[DEBUG] Parsed webRoles: $($webRoles | ConvertTo-Json -Depth 5)"
            foreach ($role in $webRoles) {
                if ($role.adx_webroleid) { $webRoleNameLookup[$role.adx_webroleid] = $role.adx_name }
            }
            $mdContent += "## Web Roles`n| Name | Description | Authenticated | Anonymous | ID |`n|---|---|---|---|---|`n"
            foreach ($role in $webRoles) {
                $mdContent += "| $($role.adx_name) | $($role.adx_description) | $($role.adx_authenticatedusersrole) | $($role.adx_anonymoususersrole) | $($role.adx_webroleid) |`n"
            }
            $mdContent += "`n"
        }
        else {
            Write-Host "[DEBUG] No webRoles parsed from $webRoleFile"
        }
    }

    # Page Permissions
    if (Test-Path $webPageRuleFile) {
        $pagePermContent = Get-Content $webPageRuleFile
        $pagePerms = Convert-YamlObjectListWithArrays $pagePermContent
        if ($null -ne $pagePerms) {
            if ($pagePerms -isnot [System.Collections.IEnumerable] -or $pagePerms -is [string]) {
                $pagePerms = @($pagePerms)
            }
            # DEBUG: Output parsed pagePerms
            # Write-Host "[DEBUG] Parsed pagePerms: $($pagePerms | ConvertTo-Json -Depth 5)"
            $mdContent += "## Page Permissions`n| Name | Right | Scope | Web Roles | Page Name | Rule ID |`n|---|---|---|---|---|---|`n"
            foreach ($perm in $pagePerms) {
                $roleNames = @()
                if ($perm['adx_webpageaccesscontrolrule_webrole']) {
                    foreach ($roleId in $perm['adx_webpageaccesscontrolrule_webrole']) {
                        if ($webRoleNameLookup.ContainsKey($roleId)) {
                            $roleNames += $webRoleNameLookup[$roleId]
                        }
                        else {
                            $roleNames += $roleId
                        }
                    }
                }
                $roles = $roleNames -join ', '
                $pageName = $perm['adx_webpageid']
                if ($perm['adx_webpageid']) {
                    $lookupKey = ($perm['adx_webpageid']).ToString().Trim().ToLower()
                    if ($webPageNameLookup.ContainsKey($lookupKey)) {
                        $pageName = $webPageNameLookup[$lookupKey]
                    }
                }
                $mdContent += "| $($perm['adx_name']) | $($perm['adx_right']) | $($perm['adx_scope']) | $roles | $pageName | $($perm['adx_webpageaccesscontrolruleid']) |`n"
            }
            $mdContent += "`n"
        }
        else {
            Write-Host "[DEBUG] No pagePerms parsed from $webPageRuleFile"
        }
    }

    # Table Permissions
    if (Test-Path $tablePermFolder) {
        $tablePermFiles = Get-ChildItem -Path $tablePermFolder -Filter '*.tablepermission.yml'
        $tablePerms = @()
        $permLookup = @{}
        foreach ($permFile in $tablePermFiles) {
            $permContent = Get-Content $permFile.FullName
            $perm = Convert-YamlFlatWithArrays $permContent
            if ($null -ne $perm) {
                if ($perm -isnot [System.Collections.IEnumerable] -or $perm -is [string]) {
                    $perm = @($perm)
                }
                foreach ($p in $perm) {
                    if ($null -ne $p -and $p.ContainsKey('adx_entitypermissionid')) {
                        $tablePerms += $p
                        $permLookup[$p['adx_entitypermissionid']] = $p
                    }
                }
            }
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
                    }
                    else {
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
            $scopeValue = $perm['adx_scope']
            $scopeDisplay = $scopeValue
            if ($scopeMap.ContainsKey($scopeValue.ToString())) {
                $scopeDisplay = $scopeMap[$scopeValue.ToString()]
            }
            $nbsp = '&nbsp;' * 4 * $depth
            $arrow = [char]0x21B3
            $displayName = if ($depth -gt 0) { "$nbsp$arrow $($perm['adx_entityname'])" } else { "$nbsp$($perm['adx_entityname'])" }
            [void]$mdTableContent.AppendLine("| $displayName | $($perm['adx_entitylogicalname']) | $($perm['adx_read']) | $($perm['adx_write']) | $($perm['adx_create']) | $($perm['adx_delete']) | $($perm['adx_append']) | $($perm['adx_appendto']) | $scopeDisplay | $roles | $($perm['adx_entitypermissionid']) |")
            
            if ($childrenLookup.ContainsKey($perm['adx_entitypermissionid'])) {
                $children = $childrenLookup[$perm['adx_entitypermissionid']] | Sort-Object adx_entityname
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

        $roots = $tablePerms | Where-Object { -not $_['adx_parententitypermission'] } | Sort-Object { $_['adx_entityname'].ToLower() }        
        foreach ($root in $roots) {
            Write-PermissionRow -perm $root -permLookup $permLookup -childrenLookup $childrenLookup -mdTableContent $mdTableContent -depth 0
        }

        $mdContent += $mdTableContent.ToString()
        $mdContent += "`n"
    }

    # Site Settings (append at end)
    if (Test-Path $siteSettingFile) {
        $siteSettingContent = Get-Content $siteSettingFile
        $siteSettings = Convert-YamlObjectList $siteSettingContent
        if ($null -ne $siteSettings) {
            if ($siteSettings -isnot [System.Collections.IEnumerable] -or $siteSettings -is [string]) {
                $siteSettings = @($siteSettings)
            }
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
    }

    # Write to Markdown file
    Set-Content -Path $mdPath -Value ($mdContent + $siteSettingsSection) -Encoding UTF8
}
