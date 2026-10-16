# Meteo v2 Prompt Maps Setup - applies the Meteo fixes to Prompt Studio maps.
param([string]$Path)

$ErrorActionPreference = 'Stop'

$DocsUrl = 'https://docs.meteostudios.net/packages/meteo-v2-package'

# Folder names as they come from the CFX portal
$ExpectedMaps = @(
    '[Prompt_Prison_Completed]', 'cfx_prompt_blaine_county_hall',
    'prompt_ammunation_rework', 'prompt_arcade_games', 'prompt_barber', 'prompt_burger_shot',
    'prompt_chinese_casino', 'prompt_hornys_sandy_only', 'prompt_mrpd', 'prompt_pillbox_hospital',
    'prompt_sandy_apts', 'prompt_sandy_beaches', 'prompt_sandy_cityhall', 'prompt_sandy_hospital2',
    'prompt_sandy_classic_car_dealership', 'prompt_sandy_corner', 'prompt_sandy_downtown',
    'prompt_sandy_houses_part1', 'prompt_sandy_market', 'prompt_sandy_mechanic', 'prompt_sandy_motel',
    'prompt_sandy_roads', 'prompt_sandy_shared', 'prompt_sandy_sheriff', 'prompt_tattoo'
)

# Made by Prompt's tool, not the portal
$SandyDataFolder = 'cfx_prompt_sandy_mapdata'

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

# ---------------------------------------------------------------------------
# Finding the folder
# ---------------------------------------------------------------------------

function Test-ServerFolder([string]$dir) {
    if (-not $dir) { return $false }
    return [IO.File]::Exists((Combine $dir 'server.cfg')) -and [IO.Directory]::Exists((Combine $dir 'resources'))
}

function Test-MapsFolder([string]$dir) {
    if (-not $dir -or -not [IO.Directory]::Exists($dir)) { return $false }
    if ([IO.Path]::GetFileName($dir) -eq '[prompt-maps]') { return $true }
    foreach ($name in $ExpectedMaps) {
        if ([IO.Directory]::Exists((Combine $dir $name))) { return $true }
    }
    return $false
}

function Get-MapsFromServer([string]$server) {
    return Combine (Combine (Combine $server 'resources') '[assets]') '[prompt-maps]'
}

# Accepts the maps folder or the server folder
function Resolve-MapsFolder([string]$p) {
    if (-not $p) { return $null }
    $p = $p.Trim().Trim('"').TrimEnd('\')
    if (-not [IO.Directory]::Exists($p)) { return $null }
    $p = [IO.Path]::GetFullPath($p).TrimEnd('\')
    if (Test-ServerFolder $p) {
        $maps = Get-MapsFromServer $p
        if ([IO.Directory]::Exists($maps)) { return $maps }
        return $null
    }
    if (Test-MapsFolder $p) { return $p }
    return $null
}

function Find-MapsFolder {
    $here = $PSScriptRoot
    $parent = [IO.Path]::GetDirectoryName($here)
    $candidates = @($here)
    if ($parent) { $candidates += @($parent, (Combine $parent 'server-data')) }
    $candidates += (Combine $here 'server-data')
    foreach ($c in $candidates) {
        if (Test-ServerFolder $c) {
            $maps = Get-MapsFromServer $c
            if ([IO.Directory]::Exists($maps)) { return [IO.Path]::GetFullPath($maps).TrimEnd('\') }
        }
    }
    return $null
}

function Read-MapsFolder {
    while ($true) {
        Say 'Could not find your [prompt-maps] folder automatically.'
        Say 'Tip: drag the [prompt-maps] folder (or your server folder) into this window, then press Enter.'
        $p = Read-Host '  Folder (Enter to cancel)'
        if (-not $p) { return $null }
        $found = Resolve-MapsFolder $p
        if ($found) { return $found }
        Fail 'No Prompt Studio maps found there.'
        Write-Host ''
    }
}

function Confirm-ServerStopped {
    while (Get-Process -Name 'FXServer' -ErrorAction SilentlyContinue) {
        Write-Host ''
        Warn 'A FiveM server (FXServer) is running.'
        Say 'Stop it in txAdmin first - a running server locks the map folders.' 'Yellow'
        $a = Read-Host '  [R]etry after stopping, [I]gnore (it is another server), [C]ancel'
        if ($a -match '^[iI]') { return $true }
        if ($a -notmatch '^[rR]') { return $false }
    }
    return $true
}

# ---------------------------------------------------------------------------
# Text files
# ---------------------------------------------------------------------------

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

# Encrypted files can't be edited
function Test-Escrowed([string]$path) {
    $fs = [IO.File]::OpenRead($path)
    try {
        $head = New-Object byte[] 4
        $n = $fs.Read($head, 0, 4)
        return $n -eq 4 -and [Text.Encoding]::ASCII.GetString($head) -eq 'FXAP'
    } finally { $fs.Dispose() }
}

function Test-InComment([string]$text, [int]$index) {
    $lineStart = Get-LineStart $text $index
    return $text.Substring($lineStart, $index - $lineStart).Contains('--')
}

# Index of the closing brace
function Find-BlockEnd([string]$text, [int]$open) {
    $depth = 0
    $i = $open
    while ($i -lt $text.Length) {
        $c = $text[$i]
        if ($c -eq '-' -and $i + 1 -lt $text.Length -and $text[$i + 1] -eq '-') {
            $nl = $text.IndexOf("`n", $i)
            if ($nl -lt 0) { return -1 }
            $i = $nl + 1
            continue
        }
        if ($c -eq '"' -or $c -eq "'") {
            $j = $i + 1
            while ($j -lt $text.Length -and $text[$j] -ne $c -and $text[$j] -ne "`n") {
                if ($text[$j] -eq '\') { $j++ }
                $j++
            }
            $i = $j + 1
            continue
        }
        if ($c -eq '{') { $depth++ }
        elseif ($c -eq '}') {
            $depth--
            if ($depth -eq 0) { return $i }
        }
        $i++
    }
    return -1
}

function Get-LineStart([string]$text, [int]$index) {
    if ($index -le 0) { return 0 }
    return $text.LastIndexOf("`n", $index - 1) + 1
}

# Comments lines at their shared indent
function Add-LineComments([string]$chunk) {
    $lines = [regex]::Split($chunk, '(?<=\n)')
    $indent = [int]::MaxValue
    foreach ($l in $lines) {
        if ($l.Trim().Length -eq 0) { continue }
        $n = $l.Length - $l.TrimStart(' ', "`t").Length
        if ($n -lt $indent) { $indent = $n }
    }
    if ($indent -eq [int]::MaxValue) { return $chunk }
    $out = New-Object Text.StringBuilder
    foreach ($l in $lines) {
        if ($l.Trim().Length -eq 0) { [void]$out.Append($l); continue }
        [void]$out.Append($l.Substring(0, $indent)).Append('-- ').Append($l.Substring($indent))
    }
    return $out.ToString()
}

function Test-AllCommented([string]$chunk) {
    foreach ($l in [regex]::Split($chunk, '\r?\n')) {
        $t = $l.Trim()
        if ($t.Length -gt 0 -and -not $t.StartsWith('--')) { return $false }
    }
    return $true
}

# ---------------------------------------------------------------------------
# Fix types - each returns the new text, or $null when the spot is not found
# ---------------------------------------------------------------------------

# key = true/false inside the block after the anchor
function Set-Flag([string]$text, [string]$anchor, [string]$key, [string]$value) {
    $start = 0
    $limit = $text.Length
    if ($anchor) {
        $a = [regex]::Match($text, $anchor)
        if (-not $a.Success) { return $null }
        $start = $a.Index
        $open = $text.IndexOf('{', $a.Index)
        if ($open -ge 0 -and $open -lt $a.Index + $a.Length) {
            $close = Find-BlockEnd $text $open
            if ($close -gt 0) { $limit = $close }
        }
    }
    $pattern = '(?<![\w.])(' + $key + '\s*=\s*)(true|false)\b'
    $m = [regex]::Match($text.Substring(0, $limit), $pattern)
    while ($m.Success -and ($m.Index -lt $start -or (Test-InComment $text $m.Index))) { $m = $m.NextMatch() }
    if (-not $m.Success) { return $null }
    $g = $m.Groups[2]
    return $text.Substring(0, $g.Index) + $value + $text.Substring($g.Index + $g.Length)
}

# Comments out a whole top-level block
function Hide-Block([string]$text, [string]$name, [string]$mustContain) {
    $m = [regex]::Match($text, '(?m)^' + [regex]::Escape($name) + '\s*\{')
    if (-not $m.Success) {
        if ($text -match ('(?m)^\s*--\s*' + [regex]::Escape($name) + '\s*\{')) { return $text }
        return $null
    }
    $close = Find-BlockEnd $text ($m.Index + $m.Length - 1)
    if ($close -lt 0) { return $null }
    $end = $text.IndexOf("`n", $close)
    if ($end -lt 0) { $end = $text.Length } else { $end++ }
    $chunk = $text.Substring($m.Index, $end - $m.Index)
    if ($mustContain -and -not $chunk.Contains($mustContain)) { return $null }
    return $text.Substring(0, $m.Index) + (Add-LineComments $chunk) + $text.Substring($end)
}

# key = "text" anywhere in the file
function Set-Text([string]$text, [string]$key, [string]$value) {
    $m = [regex]::Match($text, '(?m)^([ \t]*' + $key + '\s*=\s*)(["''])([^"'']*)(["''])')
    if (-not $m.Success) { return $null }
    $g = $m.Groups[3]
    return $text.Substring(0, $g.Index) + $value + $text.Substring($g.Index + $g.Length)
}

# Comments out entries inside one block
function Hide-Entries([string]$text, [string]$block, [string[]]$entries) {
    foreach ($e in $entries) {
        $head = [regex]::Match($text, '(?m)^' + [regex]::Escape($block) + '\s*\{')
        if (-not $head.Success) { return $null }
        $open = $head.Index + $head.Length - 1
        $close = Find-BlockEnd $text $open
        if ($close -lt 0) { return $null }
        $body = $text.Substring($open, $close - $open)
        $q = "['""]" + [regex]::Escape($e) + "['""]"
        $m = [regex]::Match($body, '(?m)^([ \t]*)(' + $q + ')')
        if (-not $m.Success) {
            if ($body -match ('(?m)^[ \t]*--[ \t]*' + $q)) { continue }
            return $null
        }
        $at = $open + $m.Groups[2].Index
        $text = $text.Substring(0, $at) + '-- ' + $text.Substring($at)
    }
    return $text
}

# Comments out what is inside a table
function Hide-BlockBody([string]$text, [string]$anchor) {
    $m = [regex]::Match($text, $anchor)
    if (-not $m.Success) { return $null }
    $open = $text.IndexOf('{', $m.Index)
    $close = Find-BlockEnd $text $open
    if ($close -lt 0) { return $null }
    $bodyStart = $text.IndexOf("`n", $open) + 1
    $bodyEnd = Get-LineStart $text $close
    if ($bodyStart -le 0 -or $bodyEnd -le $bodyStart) { return $text }
    $chunk = $text.Substring($bodyStart, $bodyEnd - $bodyStart)
    if (Test-AllCommented $chunk) { return $text }
    return $text.Substring(0, $bodyStart) + (Add-LineComments $chunk) + $text.Substring($bodyEnd)
}

# ---------------------------------------------------------------------------
# The fixes
# ---------------------------------------------------------------------------

$FileFixes = @(
    @{
        Map = 'prompt_mrpd'; File = 'config.lua'
        Label = 'MRPD: turn off the standalone layer and its teleport elevator'
        Apply = {
            param($t)
            $t = Set-Flag $t 'Config\.Standalone\s*=\s*\{' 'enabled' 'false'
            if ($null -eq $t) { return $null }
            return Set-Flag $t '\belevator\s*=\s*\{' 'enabled' 'false'
        }
    },
    @{
        Map = 'prompt_pillbox_hospital'; File = 'pillbox_scripts\config.lua'
        Label = 'Pillbox: turn off the MRI and elevator modules'
        Apply = {
            param($t)
            $t = Set-Flag $t 'Config\.Modules\s*=\s*\{' 'mri' 'false'
            if ($null -eq $t) { return $null }
            return Set-Flag $t 'Config\.Modules\s*=\s*\{' 'elevator' 'false'
        }
    },
    @{
        Map = 'prompt_pillbox_hospital'; File = 'fxmanifest.lua'
        Label = 'Pillbox: stop loading its scripts (map only)'
        Apply = {
            param($t)
            foreach ($b in @('shared_scripts', 'client_scripts', 'server_scripts')) {
                $t = Hide-Block $t $b 'pillbox_scripts/'
                if ($null -eq $t) { return $null }
            }
            return $t
        }
    },
    @{
        Map = 'prompt_sandy_hospital2'; File = 'fxmanifest.lua'
        Label = 'Sandy Hospital: stop loading its MRI, beds, chairs, elevator and debug scripts'
        Apply = {
            param($t)
            $t = Hide-Entries $t 'client_scripts' @('client/elevator.lua', 'client/mri.lua', 'client/beds.lua', 'client/debug.lua')
            if ($null -eq $t) { return $null }
            return Hide-Entries $t 'server_scripts' @('server/mri.lua', 'server/seats.lua')
        }
    },
    @{
        Map = 'prompt_sandy_apts'; File = 'config.lua'
        Label = 'Sandy Apartments: empty shells, debug off'
        Apply = {
            param($t)
            $t = Set-Text $t 'Config\.InteriorMode' 'shell_only'
            if ($null -eq $t) { return $null }
            return Set-Flag $t $null 'Config\.Debug' 'false'
        }
    },
    @{
        Map = 'prompt_sandy_houses_part1'; File = 'config.lua'
        Label = 'Sandy Houses: empty shells, no furniture'
        Apply = { param($t) Set-Text $t 'Config\.HouseMode' 'shells_only' }
    },
    @{
        Map = 'prompt_sandy_mechanic'; File = 'config.lua'
        Label = 'Sandy Mechanic: remove the lift props'
        Apply = { param($t) Hide-BlockBody $t '\bProps\s*=\s*\{' }
    },
    @{
        Map = '[Prompt_Prison_Completed]'; File = 'prompt_prison_study\config.lua'
        Label = 'Prison: turn off debug prints and the gym sets command'
        Apply = {
            param($t)
            $t = Set-Flag $t 'return\s*\{' 'Debug' 'false'
            if ($null -eq $t) { return $null }
            return Set-Flag $t '\bgymSets\s*=\s*\{' 'enable' 'false'
        }
    }
)

$FolderFixes = @(
    @{
        Map = 'prompt_barber'; Folder = 'stream\sandy'
        Label = 'Barber: remove the Sandy barber (clashes with the Sandy maps)'
    }
)

# ---------------------------------------------------------------------------
# Plan
# ---------------------------------------------------------------------------

function Get-Plan([string]$maps) {
    $plan = New-Object System.Collections.Generic.List[object]
    foreach ($f in $FileFixes) {
        $mapDir = Combine $maps $f.Map
        $path = Combine $mapDir $f.File
        $item = [pscustomobject]@{ Kind = 'file'; Label = $f.Label; Path = $path; Status = ''; File = $null; NewText = $null }
        if (-not [IO.Directory]::Exists($mapDir)) { $item.Status = 'notinstalled' }
        elseif (-not [IO.File]::Exists($path)) { $item.Status = 'changed' }
        else {
            try {
                if (Test-Escrowed $path) { $item.Status = 'changed' }
                else {
                    $file = Read-TextFile $path
                    $new = & $f.Apply $file.Text
                    if ($null -eq $new) { $item.Status = 'changed' }
                    elseif ($new -ceq $file.Text) { $item.Status = 'done' }
                    else { $item.Status = 'todo'; $item.File = $file; $item.NewText = $new }
                }
            } catch { $item.Status = 'locked' }
        }
        $plan.Add($item)
    }
    foreach ($f in $FolderFixes) {
        $mapDir = Combine $maps $f.Map
        $path = Combine $mapDir $f.Folder
        $item = [pscustomobject]@{ Kind = 'folder'; Label = $f.Label; Path = $path; Status = '' }
        if (-not [IO.Directory]::Exists($mapDir)) { $item.Status = 'notinstalled' }
        elseif ([IO.Directory]::Exists($path)) { $item.Status = 'todo' }
        else { $item.Status = 'done' }
        $plan.Add($item)
    }
    return ,$plan
}

function Show-Plan($plan) {
    foreach ($p in $plan) {
        switch ($p.Status) {
            'todo'         { Say "[fix]     $($p.Label)" 'Cyan' }
            'done'         { Say "[ok]      $($p.Label) - already done" 'Green' }
            'notinstalled' { Say "[skip]    $($p.Label) - map not installed" 'DarkGray' }
            'changed'      { Warn "$($p.Label) - could not find the setting. Prompt may have updated this map, check it by hand." }
            'locked'       { Warn "$($p.Label) - file is in use by another program, close it and run again." }
        }
    }
}

function Show-MapCheck([string]$maps) {
    $missing = @()
    foreach ($name in $ExpectedMaps) {
        $dir = Combine $maps $name
        if (-not [IO.Directory]::Exists($dir)) { $missing += $name; continue }
        $nested = Combine $dir $name
        if ([IO.Directory]::Exists($nested) -and -not [IO.File]::Exists((Combine $dir 'fxmanifest.lua'))) {
            Warn "$name is inside an extra $name folder. Move the inner folder up one level."
        }
    }
    Say "Maps found: $($ExpectedMaps.Count - $missing.Count) of $($ExpectedMaps.Count)"
    if ($missing.Count -gt 0) {
        Say 'Not installed (fine if you do not own them):' 'DarkGray'
        foreach ($m in $missing) { Say "  - $m" 'DarkGray' }
    }

    $sandy = @($ExpectedMaps | Where-Object { $_ -match 'sandy' -and $_ -ne 'prompt_sandy_shared' -and $missing -notcontains $_ })
    if ($sandy.Count -gt 0 -and -not [IO.Directory]::Exists((Combine $maps $SandyDataFolder))) {
        Write-Host ''
        Warn "Sandy maps found but no $SandyDataFolder folder."
        Say '  1. Start the server once. The console prints a link to the Prompt map data tool.' 'Yellow'
        Say '  2. Make the map data there for the Sandy maps you own.' 'Yellow'
        Say "  3. Put the $SandyDataFolder folder in [prompt-maps] and restart." 'Yellow'
        Say '  Make it again whenever you add or remove a Sandy map.' 'Yellow'
    }
}

# ---------------------------------------------------------------------------
# Apply
# ---------------------------------------------------------------------------

function Invoke-Plan($todo) {
    # Folders go last, files can roll back
    $files = @($todo | Where-Object { $_.Kind -eq 'file' })
    $folders = @($todo | Where-Object { $_.Kind -eq 'folder' })
    $written = New-Object System.Collections.Generic.List[object]
    try {
        foreach ($p in $files) {
            $original = [IO.File]::ReadAllBytes($p.Path)
            [IO.File]::WriteAllBytes($p.Path, (Get-TextBytes $p.File $p.NewText))
            $written.Add([pscustomobject]@{ Path = $p.Path; Bytes = $original })
            Say "[done]    $($p.Label)" 'Green'
        }
    } catch {
        Fail (Get-ErrorText $_)
        Warn 'Putting the files back the way they were...'
        foreach ($w in $written) {
            try { [IO.File]::WriteAllBytes($w.Path, $w.Bytes) } catch { Fail "Could not restore $($w.Path)" }
        }
        return $false
    }
    foreach ($p in $folders) {
        try {
            [IO.Directory]::Delete($p.Path, $true)
            Say "[done]    $($p.Label)" 'Green'
        } catch { Fail "$($p.Label) - $(Get-ErrorText $_)"; return $false }
    }
    return $true
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

try { $Host.UI.RawUI.WindowTitle = 'Meteo v2 Prompt Maps Setup' } catch { }
Write-Host ''
Say 'Meteo v2 Prompt Maps Setup' 'White'
Say 'Applies the Meteo fixes to your Prompt Studio maps. Run it again after every map update.'
Say 'Only the fixes listed below are applied, nothing else is touched.' 'DarkGray'
Write-Host ''

try {
    $maps = $null
    if ($Path) {
        $maps = Resolve-MapsFolder $Path
        if (-not $maps) { Fail "No Prompt Studio maps found in $Path" }
    }
    if (-not $maps) { $maps = Find-MapsFolder }
    if (-not $maps) { $maps = Read-MapsFolder }
    if (-not $maps) { Say 'Cancelled.'; Close-Tool 1 }

    Say "Maps folder: $maps" 'White'
    Show-MapCheck $maps
    Write-Host ''

    if (-not (Confirm-ServerStopped)) { Say 'Cancelled.'; Close-Tool 1 }

    $plan = Get-Plan $maps
    Show-Plan $plan
    $todo = @($plan | Where-Object { $_.Status -eq 'todo' })
    Write-Host ''

    if ($todo.Count -eq 0) {
        Say 'Nothing to change.' 'Green'
        Close-Tool 0
    }

    $a = Read-Host "  Apply $($todo.Count) fix(es)? [Y]es / [N]o"
    if ($a -notmatch '^[yY]') { Say 'Cancelled. Nothing was changed.'; Close-Tool 1 }
    Write-Host ''

    $ok = Invoke-Plan $todo
    Write-Host ''
    if (-not $ok) { Close-Tool 1 }
    Say 'All done. Restart your server to load the changes.' 'Green'
    Say "Help: $DocsUrl" 'DarkGray'
    Close-Tool 0
} catch {
    Fail (Get-ErrorText $_)
    Close-Tool 1
}
