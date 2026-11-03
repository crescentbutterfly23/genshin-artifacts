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
<script src="config.js"></script>
'''
body=src.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','')
i=body.index("<style>");j=body.index("</style>")+len("</style>")
out=head+body[:j]+"\n</head>\n<body>\n"+body[j:]+"\n</body>\n</html>\n"
pathlib.Path("index.html").write_text(out)
print("index.html", len(out)//1024, "KB")
