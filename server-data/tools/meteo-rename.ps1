# Meteo v2 Rename - changes the Meteo script prefix.
param([string]$Path)

$ErrorActionPreference = 'Stop'

$DefaultPrefix = 'meteo-'
# Reserved by other frameworks
$BlockedPrefixes = @('qb', 'qbx', 'ox', 'esx', 'cfx')
$BackupFolderName = 'rename-backups'
$DocsUrl = 'https://docs.meteostudios.net/packages/meteo-v2-package/how-to/how-to-rename-meteo-scripts'
$PrefixValuePattern = "(Rename\.prefix\s*=\s*['""])([^'""]*)(['""])"
$NameChar = 'A-Za-z0-9_\-'

function Say([string]$text, [string]$color = 'Gray') { Write-Host "  $text" -ForegroundColor $color }
function Warn([string]$text) { Say "[warn] $text" 'Yellow' }
function Fail([string]$text) { Say "[error] $text" 'Red' }

function Get-ErrorText($err) {
    $e = $err.Exception
    while ($e.InnerException) { $e = $e.InnerException }
    return $e.Message
}

function Close-Tool([int]$code) {
    Write-Host ''
    Read-Host '  Press Enter to close' | Out-Null
    exit $code
}

function Combine([string]$a, [string]$b) { return [IO.Path]::Combine($a, $b) }

function Get-RelativePath([string]$root, [string]$full) {
    return $full.Substring($root.Length).TrimStart('\')
}

function Test-ServerFolder([string]$dir) {
    if (-not $dir) { return $false }
    return [IO.File]::Exists((Combine $dir 'server.cfg')) -and [IO.Directory]::Exists((Combine $dir 'resources'))
}

function Find-ServerFolder {
    $here = $PSScriptRoot
    $parent = [IO.Path]::GetDirectoryName($here)
    $candidates = @($here)
    if ($parent) { $candidates += @($parent, (Combine $parent 'server-data')) }
    $candidates += (Combine $here 'server-data')
    foreach ($c in $candidates) {
        if (Test-ServerFolder $c) { return [IO.Path]::GetFullPath($c).TrimEnd('\') }
    }
    return $null
}

function Read-ServerFolder {
    while ($true) {
        Say 'Could not find your server folder automatically.'
        Say 'Tip: drag the folder that has server.cfg into this window, then press Enter.'
        $p = Read-Host '  Server folder (Enter to cancel)'
        if (-not $p) { return $null }
        $p = $p.Trim().Trim('"').TrimEnd('\')
        if (Test-ServerFolder $p) { return [IO.Path]::GetFullPath($p).TrimEnd('\') }
        Fail 'No server.cfg and resources folder there.'
        Write-Host ''
    }
}

function Confirm-ServerStopped {
    while (Get-Process -Name 'FXServer' -ErrorAction SilentlyContinue) {
        Write-Host ''
        Warn 'A FiveM server (FXServer) is running.'
        Say 'Stop it in txAdmin first - a running server locks the script folders.' 'Yellow'
        $a = Read-Host '  [R]etry after stopping, [I]gnore (it is another server), [C]ancel'
        if ($a -match '^[iI]') { return $true }
        if ($a -notmatch '^[rR]') { return $false }
    }
    return $true
}

function Read-TextFile([string]$path) {
    $bytes = [IO.File]::ReadAllBytes($path)
    $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $offset = 0
    if ($bom) { $offset = 3 }
    $strict = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        $text = $strict.GetString($bytes, $offset, $bytes.Length - $offset)
        $ansi = $false
    } catch {
        $text = [Text.Encoding]::Default.GetString($bytes)
        $ansi = $true
    }
    return @{ Text = $text; Bom = $bom; Ansi = $ansi }
}

function Get-TextBytes($file, [string]$text) {
    if ($file.Ansi) { return [Text.Encoding]::Default.GetBytes($text) }
    $body = (New-Object System.Text.UTF8Encoding($false)).GetBytes($text)
    if ($file.Bom) { return [byte[]](@(0xEF, 0xBB, 0xBF) + $body) }
    return $body
}

# Encrypted files are skipped
function Test-Escrowed([string]$path) {
    $fs = [IO.File]::OpenRead($path)
    try {
        $head = New-Object byte[] 4
        $n = $fs.Read($head, 0, 4)
        return $n -eq 4 -and [Text.Encoding]::ASCII.GetString($head) -eq 'FXAP'
    } finally { $fs.Dispose() }
}

function Get-ResourceFolders([string]$root) {
    $found = New-Object System.Collections.Generic.List[string]
    $stack = New-Object System.Collections.Generic.Stack[string]
    $stack.Push($root)
    while ($stack.Count -gt 0) {
        $dir = $stack.Pop()
        foreach ($sub in [IO.Directory]::GetDirectories($dir)) {
            $name = [IO.Path]::GetFileName($sub)
            if ($name -eq 'node_modules' -or $name.StartsWith('.')) { continue }
            if ([IO.File]::Exists((Combine $sub 'fxmanifest.lua')) -or [IO.File]::Exists((Combine $sub '__resource.lua'))) {
                $found.Add($sub)
            } else {
                $stack.Push($sub)
            }
        }
    }
    return ,$found
}

function Get-RenameFiles([string]$dir) {
    return @([IO.Directory]::GetFiles($dir, 'rename.lua', [IO.SearchOption]::AllDirectories) |
        Where-Object { $_ -notmatch '\\node_modules\\' })
}

# Only our own resources
function Test-MeteoResource([string]$dir, [string]$name) {
    if ($name.StartsWith($DefaultPrefix)) { return $true }
    if ((Get-RenameFiles $dir).Count -gt 0) { return $true }
    $manifest = Combine $dir 'fxmanifest.lua'
    try { return [IO.File]::Exists($manifest) -and ([IO.File]::ReadAllText($manifest) -match 'Meteo') }
    catch { return $false }
}

function Test-PrefixValue([string]$value) {
    return $value -cmatch '^[a-z]{1,8}-$'
}

function Get-ServerState([string]$server) {
    $resources = Combine $server 'resources'
    $folders = Get-ResourceFolders $resources

    # Read current prefix
    $prefixes = New-Object System.Collections.Generic.List[string]
    $bad = @()
    foreach ($folder in $folders) {
        foreach ($file in (Get-RenameFiles $folder)) {
            try {
                if (Test-Escrowed $file) { $bad += "$file is encrypted"; continue }
                $m = [regex]::Match((Read-TextFile $file).Text, $PrefixValuePattern)
            } catch { $bad += "$file is in use by another program - close it and try again"; continue }
            if (-not $m.Success) { continue }
            $value = $m.Groups[2].Value
            if (-not (Test-PrefixValue $value)) { $bad += "$file has an invalid prefix '$value'"; continue }
            if (-not $prefixes.Contains($value)) { $prefixes.Add($value) }
        }
    }

    $known = @($DefaultPrefix) + @($prefixes | Where-Object { $_ -ne $DefaultPrefix })
    $ours = @()
    foreach ($folder in $folders) {
        $name = [IO.Path]::GetFileName($folder)
        foreach ($p in $known) {
            if ($name.StartsWith($p) -and $name.Length -gt $p.Length -and (Test-MeteoResource $folder $name)) {
                $ours += [pscustomobject]@{ Path = $folder; Name = $name; Prefix = $p; Suffix = $name.Substring($p.Length) }
                break
            }
        }
    }

    $inUse = @($ours | ForEach-Object { $_.Prefix } | Select-Object -Unique)
    return [pscustomobject]@{
        Server = $server; Resources = $resources; Folders = $folders
        Ours = $ours; Prefixes = $known; InUse = $inUse; Problems = $bad
    }
}

function New-NamePattern([string[]]$prefixes, [string[]]$suffixes, [string]$lead) {
    $p = ($prefixes | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $s = ($suffixes | Sort-Object Length -Descending | ForEach-Object { [regex]::Escape($_) }) -join '|'
    return "$lead(?:$p)($s)(?![$NameChar])"
}

function Get-PostRenamePath([string]$path, $renames) {
    foreach ($r in $renames) {
        if ($path.StartsWith($r.Old + '\', [StringComparison]::OrdinalIgnoreCase)) {
            return $r.New + $path.Substring($r.Old.Length)
        }
    }
    return $path
}

function Get-LuaEdit([string]$file, [bool]$isRename, [string]$newPrefix, [string]$includePattern, [string]$replacement) {
    try { $escrowed = Test-Escrowed $file } catch { throw 'in use by another program - close it and try again' }
    if ($escrowed) {
        if ($isRename) { throw 'encrypted, cannot be updated' }
        return $null
    }
    $doc = Read-TextFile $file
    $text = $doc.Text
    if ($isRename) {
        $text = [regex]::Replace($text, $PrefixValuePattern, { param($m) $m.Groups[1].Value + $newPrefix + $m.Groups[3].Value })
    }
    if ($text.Contains('@')) { $text = [regex]::Replace($text, $includePattern, $replacement) }
    if ($text -ceq $doc.Text) { return $null }
    $kind = 'include'
    if ($isRename) { $kind = 'rename' }
    return [pscustomobject]@{ Path = $file; Doc = $doc; Text = $text; Kind = $kind }
}

function New-RenamePlan($state, [string]$newPrefix) {
    $errors = @()
    $renames = @()
    $targets = @{}
    foreach ($r in $state.Ours) {
        $newName = $newPrefix + $r.Suffix
        $newPath = Combine ([IO.Path]::GetDirectoryName($r.Path)) $newName
        if ($targets.ContainsKey($newPath)) { $errors += "Two scripts would both become $newName"; continue }
        $targets[$newPath] = $true
        if ($r.Name -ceq $newName) { continue }
        if ([IO.Directory]::Exists($newPath) -or [IO.File]::Exists($newPath)) {
            $errors += "$newName already exists next to $($r.Name)"
            continue
        }
        $renames += [pscustomobject]@{ Old = $r.Path; New = $newPath; OldName = $r.Name; NewName = $newName }
    }

    $from = @($state.Prefixes | Where-Object { $_ -ne $newPrefix })
    $suffixes = @($state.Ours | ForEach-Object { $_.Suffix } | Select-Object -Unique)
    $edits = @()
    $cfgLines = @()

    if ($from.Count -gt 0 -and $suffixes.Count -gt 0) {
        # Whole names only
        $namePattern = New-NamePattern $from $suffixes "(?<![$NameChar])"
        $includePattern = New-NamePattern $from $suffixes '(?<=@)'
        $replacement = $newPrefix + '$1'
        $ourPaths = @($state.Ours | ForEach-Object { $_.Path + '\' })

        # Lua files
        foreach ($file in [IO.Directory]::GetFiles($state.Resources, '*.lua', [IO.SearchOption]::AllDirectories)) {
            if ($file -match '\\node_modules\\') { continue }
            $isRename = [IO.Path]::GetFileName($file) -eq 'rename.lua' -and
                @($ourPaths | Where-Object { $file.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
            if ((New-Object IO.FileInfo $file).Length -gt 5MB) { continue }
            try {
                $edit = Get-LuaEdit $file $isRename $newPrefix $includePattern $replacement
                if ($edit) { $edits += $edit }
            } catch {
                $errors += "$(Get-RelativePath $state.Server $file): $(Get-ErrorText $_)"
            }
        }

        # cfg files
        foreach ($file in [IO.Directory]::GetFiles($state.Server, '*.cfg')) {
            try { $doc = Read-TextFile $file }
            catch { $errors += "$([IO.Path]::GetFileName($file)) is in use by another program - close it and try again"; continue }
            $text = [regex]::Replace($doc.Text, $namePattern, $replacement)
            if ($text -ceq $doc.Text) { continue }
            $edits += [pscustomobject]@{ Path = $file; Doc = $doc; Text = $text; Kind = 'cfg' }
            $old = $doc.Text -split "`r?`n"
            $new = $text -split "`r?`n"
            for ($i = 0; $i -lt [Math]::Min($old.Count, $new.Count); $i++) {
                if ($old[$i] -cne $new[$i]) {
                    $cfgLines += [pscustomobject]@{ File = [IO.Path]::GetFileName($file); Line = $i + 1; Old = $old[$i].Trim(); New = $new[$i].Trim() }
                }
            }
        }
    }

    foreach ($e in $edits) { $e | Add-Member -NotePropertyName After -NotePropertyValue (Get-PostRenamePath $e.Path $renames) }
    return [pscustomobject]@{ Prefix = $newPrefix; Renames = $renames; Edits = $edits; CfgLines = $cfgLines; Errors = $errors }
}

function Show-Plan($plan) {
    Write-Host ''
    Say '----------------------------------------------------' 'DarkGray'
    Say "New prefix: $($plan.Prefix)" 'Cyan'
    Write-Host ''
    Say "Folders to rename: $($plan.Renames.Count)"
    $shown = 0
    foreach ($r in $plan.Renames) {
        if ($shown -ge 8) { Say "   ... and $($plan.Renames.Count - 8) more" 'DarkGray'; break }
        Say "   $($r.OldName) -> $($r.NewName)" 'DarkGray'
        $shown++
    }
    Say "rename.lua files: $(@($plan.Edits | Where-Object { $_.Kind -eq 'rename' }).Count)"
    Say "Lua files with @includes: $(@($plan.Edits | Where-Object { $_.Kind -eq 'include' }).Count)"
    Say "cfg lines: $($plan.CfgLines.Count)"
    foreach ($c in $plan.CfgLines) {
        Say "   $($c.File):$($c.Line)  $($c.Old)" 'DarkGray'
        Say "   $(' ' * ($c.File.Length + 1 + "$($c.Line)".Length))  -> $($c.New)" 'Gray'
    }
    Say '----------------------------------------------------' 'DarkGray'
}

function Undo-FolderRenames($done) {
    $failed = @()
    for ($i = $done.Count - 1; $i -ge 0; $i--) {
        try { [IO.Directory]::Move($done[$i].New, $done[$i].Old) } catch { $failed += $done[$i].NewName }
    }
    return $failed
}

function Invoke-Plan($state, $plan) {
    $server = $state.Server
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Combine (Combine $server $BackupFolderName) $stamp
    $filesDir = Combine $backup 'files'

    # Back up first
    foreach ($e in $plan.Edits) {
        $dest = Combine $filesDir (Get-RelativePath $server $e.Path)
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest)) | Out-Null
        [IO.File]::Copy($e.Path, $dest, $true)
    }
    $journal = [ordered]@{
        created = (Get-Date).ToString('s')
        prefix  = $plan.Prefix
        renames = @($plan.Renames | ForEach-Object { [ordered]@{ old = (Get-RelativePath $server $_.Old); new = (Get-RelativePath $server $_.New) } })
        files   = @($plan.Edits | ForEach-Object { [ordered]@{ before = (Get-RelativePath $server $_.Path); after = (Get-RelativePath $server $_.After) } })
    }
    [IO.Directory]::CreateDirectory($backup) | Out-Null
    [IO.File]::WriteAllText((Combine $backup 'journal.json'), ($journal | ConvertTo-Json -Depth 5))

    # Rename folders
    $done = @()
    foreach ($r in $plan.Renames) {
        try {
            [IO.Directory]::Move($r.Old, $r.New)
            $done += $r
        } catch {
            Fail "Could not rename $($r.OldName): $(Get-ErrorText $_)"
            Say 'Something has a file open in it (server, editor, explorer window).' 'Yellow'
            $left = Undo-FolderRenames $done
            if ($left.Count) { Fail "Could not put back: $($left -join ', ') - use Undo from the menu." }
            else {
                Remove-FailedBackup $backup
                Say 'Nothing was changed. Close what is using the folder and try again.' 'Yellow'
            }
            return $false
        }
    }

    # Write files
    $written = @()
    try {
        foreach ($e in $plan.Edits) {
            [IO.File]::WriteAllBytes($e.After, (Get-TextBytes $e.Doc $e.Text))
            $written += $e
        }
    } catch {
        Fail "Could not write $($e.After): $(Get-ErrorText $_)"
        $restoreFailed = $false
        foreach ($w in $written) {
            try { [IO.File]::Copy((Combine $filesDir (Get-RelativePath $server $w.Path)), $w.After, $true) } catch { $restoreFailed = $true }
        }
        $left = Undo-FolderRenames $done
        if ($left.Count -or $restoreFailed) { Fail 'Could not put everything back - use Undo from the menu.' }
        else {
            Remove-FailedBackup $backup
            Say 'Everything was put back. Nothing was changed.' 'Yellow'
        }
        return $false
    }

    Write-Host ''
    Say "[ok] Renamed $($done.Count) folder(s), updated $($written.Count) file(s)." 'Green'
    Say "Backup: $backup" 'DarkGray'
    return $true
}

# Failed runs leave no backup
function Remove-FailedBackup([string]$backup) {
    try { [IO.Directory]::Delete($backup, $true) } catch { }
}

function Get-LastJournal([string]$server) {
    $root = Combine $server $BackupFolderName
    if (-not [IO.Directory]::Exists($root)) { return $null }
    $dirs = [IO.Directory]::GetDirectories($root) | Sort-Object -Descending
    foreach ($d in $dirs) {
        if ([IO.File]::Exists((Combine $d 'journal.json'))) { return $d }
    }
    return $null
}

# Stay inside the server folder
function Resolve-JournalPath([string]$server, [string]$rel) {
    if (-not $rel -or [IO.Path]::IsPathRooted($rel) -or $rel -match '(^|[\\/])\.\.([\\/]|$)') { throw "Bad path in journal: $rel" }
    $full = [IO.Path]::GetFullPath((Combine $server $rel))
    if (-not $full.StartsWith($server + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Path outside the server folder: $rel" }
    return $full
}

function Invoke-Undo([string]$server, [string]$backup) {
    try {
        $journal = [IO.File]::ReadAllText((Combine $backup 'journal.json')) | ConvertFrom-Json
        $renames = @($journal.renames | ForEach-Object {
            $old = Resolve-JournalPath $server $_.old
            $new = Resolve-JournalPath $server $_.new
            [pscustomobject]@{ Old = $old; New = $new; OldName = [IO.Path]::GetFileName($old); NewName = [IO.Path]::GetFileName($new) }
        })
        $files = @($journal.files | ForEach-Object {
            [pscustomobject]@{ Before = (Resolve-JournalPath $server $_.before); Saved = (Resolve-JournalPath $backup (Combine 'files' $_.before)) }
        })
    } catch {
        Fail "This backup cannot be used: $(Get-ErrorText $_)"
        return $false
    }

    # Folders first, then files
    $done = @()
    for ($i = $renames.Count - 1; $i -ge 0; $i--) {
        $r = $renames[$i]
        if ([IO.Directory]::Exists($r.Old)) { continue }
        if (-not [IO.Directory]::Exists($r.New)) { continue }
        try {
            [IO.Directory]::Move($r.New, $r.Old)
            $done += [pscustomobject]@{ Old = $r.New; New = $r.Old; NewName = $r.OldName }
        } catch {
            Fail "Could not rename $($r.NewName) back: $(Get-ErrorText $_)"
            Undo-FolderRenames $done | Out-Null
            Say 'Nothing was changed. Stop the server and try again.' 'Yellow'
            return $false
        }
    }
    $keep = Combine $backup 'replaced-by-undo'
    $restored = 0
    foreach ($f in $files) {
        if (-not [IO.File]::Exists($f.Saved)) { continue }
        if ([IO.File]::Exists($f.Before)) {
            $copy = Combine $keep (Get-RelativePath $server $f.Before)
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($copy)) | Out-Null
            [IO.File]::Copy($f.Before, $copy, $true)
        }
        [IO.File]::Copy($f.Saved, $f.Before, $true)
        $restored++
    }
    [IO.File]::Move((Combine $backup 'journal.json'), (Combine $backup 'journal.undone.json'))

    Write-Host ''
    Say "[ok] Undone: $($done.Count) folder(s) renamed back, $restored file(s) restored." 'Green'
    return $true
}

function Read-NewPrefix {
    while ($true) {
        Write-Host ''
        $p = Read-Host '  New prefix, 1-8 letters (e.g. abc makes abc-core), Enter to cancel'
        if (-not $p) { return $null }
        $p = $p.Trim().TrimEnd('-').ToLowerInvariant()
        if ($p -cnotmatch '^[a-z]{1,8}$') { Fail 'Use 1 to 8 letters only (a-z), no numbers or symbols.'; continue }
        if ($BlockedPrefixes -contains $p) { Fail "'$p' would make the scripts look like another framework. Pick something else."; continue }
        return "$p-"
    }
}

Clear-Host
Write-Host ''
Say 'Meteo v2 Rename' 'Cyan'
Say "Guide: $DocsUrl" 'DarkGray'
Write-Host ''

$server = $null
if ($Path) {
    $p = $Path.Trim().Trim('"').TrimEnd('\')
    if (Test-ServerFolder $p) { $server = [IO.Path]::GetFullPath($p).TrimEnd('\') }
    else { Fail "No server.cfg and resources folder in $p" }
}
if (-not $server) { $server = Find-ServerFolder }
if (-not $server) { $server = Read-ServerFolder }
if (-not $server) { Say 'Cancelled.'; Close-Tool 0 }

Say "Server folder: $server" 'Green'
Say 'Scanning scripts...'
$state = Get-ServerState $server

foreach ($problem in $state.Problems) { Fail $problem }
if ($state.Problems.Count) { Close-Tool 1 }
if ($state.Ours.Count -eq 0) {
    Fail 'No Meteo scripts found in resources.'
    Say 'Download the [meteostudios] folder from the CFX portal into resources first.' 'Yellow'
    Close-Tool 1
}

Say "Meteo scripts: $($state.Ours.Count)"
if ($state.InUse.Count -gt 1) {
    Warn "Mixed prefixes found: $($state.InUse -join ', ') - a rename did not finish."
    Say 'Pick a prefix below (or restore) to bring every script back in line.' 'Yellow'
} else {
    Say "Current prefix: $($state.InUse[0])" 'Green'
}

$lastBackup = Get-LastJournal $server
Write-Host ''
Say '1) Change prefix'
Say "2) Restore to $DefaultPrefix"
if ($lastBackup) { Say "3) Undo last rename ($([IO.Path]::GetFileName($lastBackup)))" }
Say '0) Exit'
Write-Host ''
$choice = Read-Host '  Choose'

if ($choice -eq '3' -and $lastBackup) {
    if (-not (Confirm-ServerStopped)) { Say 'Cancelled.'; Close-Tool 0 }
    $go = Read-Host '  Undo the last rename? [y/N]'
    if ($go -notmatch '^[yY]') { Say 'Cancelled.'; Close-Tool 0 }
    if (Invoke-Undo $server $lastBackup) { Close-Tool 0 } else { Close-Tool 1 }
}

$newPrefix = $null
if ($choice -eq '1') { $newPrefix = Read-NewPrefix }
elseif ($choice -eq '2') { $newPrefix = $DefaultPrefix }
if (-not $newPrefix) { Say 'Cancelled.'; Close-Tool 0 }

if (-not (Confirm-ServerStopped)) { Say 'Cancelled.'; Close-Tool 0 }

Say 'Working out the changes...'
$plan = New-RenamePlan $state $newPrefix
if ($plan.Errors.Count) {
    foreach ($e in $plan.Errors) { Fail $e }
    Say 'Nothing was changed.' 'Yellow'
    Close-Tool 1
}
if ($plan.Renames.Count -eq 0 -and $plan.Edits.Count -eq 0) {
    Say "[ok] Everything already uses $newPrefix - nothing to do." 'Green'
    Close-Tool 0
}

Show-Plan $plan
$go = Read-Host '  Apply these changes? [y/N]'
if ($go -notmatch '^[yY]') { Say 'Cancelled. Nothing was changed.'; Close-Tool 0 }

if (Invoke-Plan $state $plan) {
    Say 'Start your server again. If anything is off, run this tool and pick Undo.' 'Cyan'
    Close-Tool 0
}
Close-Tool 1
