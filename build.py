# Regenerates index.html from the single-file app (appraiser.html) for GitHub Pages:
# adds a proper document head, security headers that a static host can carry, and config.js.
import pathlib,sys
src=pathlib.Path(sys.argv[1] if len(sys.argv)>1 else "../appraiser.html").read_text()
csp=("default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
     "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.gstatic.com; "
     "img-src 'self' data: blob: https://*.supabase.co; "
     "connect-src 'self' data: blob: https://*.supabase.co wss://*.supabase.co https://enka.network; "
     "object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests")
head=f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta http-equiv="Content-Security-Policy" content="{csp}">
<meta name="referrer" content="strict-origin-when-cross-origin">
<meta name="description" content="Grade Genshin Impact artifacts, plan swaps and track your roster.">
<meta name="theme-color" content="#1B2252">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Artifact Appraiser">
<meta property="og:title" content="Artifact Appraiser">
<meta property="og:description" content="Grade Genshin Impact artifacts, plan swaps and track your roster.">
<meta property="og:url" content="https://crescentbutterfly23.github.io/genshin-artifacts/">
<meta property="og:image" content="https://crescentbutterfly23.github.io/genshin-artifacts/icons/preview.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Artifact Appraiser title screen">
<meta name="twitter:card" content="summary_large_image">
<script src="config.js"></script>
<script src="defaults/pictures.js"></script>
<link rel="icon" href="icons/icon.svg" type="image/svg+xml">
<link rel="icon" href="icons/favicon-32.png" type="image/png" sizes="32x32">
<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">
'''
body=src.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','')
i=body.index("<style>");j=body.index("</style>")+len("</style>")
out=head+body[:j]+"\n</head>\n<body>\n"+body[j:]+"\n</body>\n</html>\n"
pathlib.Path("index.html").write_text(out)
print("index.html", len(out)//1024, "KB")
