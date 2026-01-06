CREATE OR REPLACE PYTHON3 SCALAR SCRIPT github_latest_release_version(org VARCHAR(100),repo VARCHAR(200))
RETURNS VARCHAR(50)
AS
def run(ctx):
    import urllib.request,json,time
    from urllib.error import HTTPError
    if not hasattr(run,"cache"):
        run.cache={}
        run.ttl=600
    if ctx.org is None or ctx.repo is None:
        return None
    key=ctx.org+"/"+ctx.repo
    now=time.time()
    if key in run.cache:
        ts,val=run.cache[key]
        if now-ts<run.ttl:
            return val
    url="https://api.github.com/repos/"+ctx.org+"/"+ctx.repo+"/releases/latest"
    try:
        resp=urllib.request.urlopen(url,timeout=5)
        data=json.loads(resp.read().decode("utf-8"))
        val=data.get("tag_name")
        run.cache[key]=(now,val)
        return val
    except HTTPError:
        run.cache[key]=(now,None)
        return None
/
CREATE OR REPLACE PYTHON3 SCALAR SCRIPT github_latest_release_date(org VARCHAR(100),repo VARCHAR(200))
RETURNS DATE
AS
def run(ctx):
    import urllib.request,json,time
    from urllib.error import HTTPError
    if not hasattr(run,"cache"):
        run.cache={}
        run.ttl=600
    if ctx.org is None or ctx.repo is None:
        return None
    key=ctx.org+"/"+ctx.repo
    now=time.time()
    if key in run.cache:
        ts,val=run.cache[key]
        if now-ts<run.ttl:
            return val
    url="https://api.github.com/repos/"+ctx.org+"/"+ctx.repo+"/releases/latest"
    try:
        resp=urllib.request.urlopen(url,timeout=5)
        data=json.loads(resp.read().decode("utf-8"))
        pub=data.get("published_at")
        val=pub[:10] if pub else None
        run.cache[key]=(now,val)
        return val
    except HTTPError:
        run.cache[key]=(now,None)
        return None
/
