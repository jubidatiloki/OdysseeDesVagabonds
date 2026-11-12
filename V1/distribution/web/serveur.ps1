# Petit serveur web local pour L'odyssee des vagabonds (aucune installation).
# Sert le dossier "site" sur http://localhost:8088 et ouvre le navigateur.
# Fermer la fenetre pour arreter.
param([int]$Port = 8088)

$racine = Split-Path -Parent $MyInvocation.MyCommand.Path
$site = [IO.Path]::GetFullPath((Join-Path $racine 'site'))

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
try {
  $listener.Start()
} catch {
  Write-Host ""
  Write-Host " [!] Le port $Port est deja utilise : l'application est peut-etre deja ouverte."
  Write-Host "     Ouvre simplement http://localhost:$Port dans ton navigateur."
  Start-Process "http://localhost:$Port/"
  exit 1
}

Write-Host ""
Write-Host " L'odyssee des vagabonds est disponible sur http://localhost:$Port"
Write-Host " Laisse cette fenetre ouverte pendant que tu joues ; ferme-la pour arreter."
Start-Process "http://localhost:$Port/"

$types = @{
  '.html' = 'text/html; charset=utf-8'; '.js' = 'application/javascript';
  '.mjs' = 'application/javascript'; '.json' = 'application/json';
  '.wasm' = 'application/wasm'; '.css' = 'text/css'; '.png' = 'image/png';
  '.jpg' = 'image/jpeg'; '.svg' = 'image/svg+xml'; '.ico' = 'image/x-icon';
  '.ttf' = 'font/ttf'; '.otf' = 'font/otf'; '.woff' = 'font/woff';
  '.woff2' = 'font/woff2'; '.md' = 'text/markdown; charset=utf-8';
  '.txt' = 'text/plain; charset=utf-8'; '.map' = 'application/json'
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $chemin = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ([string]::IsNullOrEmpty($chemin)) { $chemin = 'index.html' }
    $fichier = [IO.Path]::GetFullPath((Join-Path $site $chemin))
    # Ne jamais sortir du dossier "site" ; page inconnue -> index.html
    if (-not $fichier.StartsWith($site) -or -not (Test-Path -LiteralPath $fichier -PathType Leaf)) {
      $fichier = Join-Path $site 'index.html'
    }
    $ext = [IO.Path]::GetExtension($fichier).ToLower()
    if ($types.ContainsKey($ext)) { $ctx.Response.ContentType = $types[$ext] }
    else { $ctx.Response.ContentType = 'application/octet-stream' }
    # Toujours la derniere version : le navigateur ne garde pas de copie.
    $ctx.Response.Headers.Add('Cache-Control', 'no-cache')
    $octets = [IO.File]::ReadAllBytes($fichier)
    $ctx.Response.ContentLength64 = $octets.Length
    $ctx.Response.OutputStream.Write($octets, 0, $octets.Length)
    $ctx.Response.OutputStream.Close()
  } catch {
    # Requete interrompue par le navigateur : on continue.
  }
}
