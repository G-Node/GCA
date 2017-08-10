import sys
import os
import json


# TODO: Include 'geo' maps


if len(sys.argv) < 4:
    print("Embeds info and schedule into the conference info.json")
    print("\n\tUsage: embedinfo.py info.json info.md schedule.json maps.json")
    print()
    sys.exit(1)

infojson, infomd, schedjson, mapjson = sys.argv[1:]

print("Embeding\n\t{}\n\t{}\n\t{}\ninto\n\t{}\n".format(
    infomd, schedjson, mapjson, infojson
))

with open(infomd) as fp:
    infopage = "".join(fp.readlines())

with open(schedjson) as fp:
    sched = "".join(fp.readlines())
    sched = sched.replace('"', '\"')

with open(mapjson) as fp:
    maps = "".join(fp.readlines())
    maps = maps.replace('"', '\"')

with open(infojson) as fp:
    confinfo = json.load(fp)

confinfo["info"] = infopage
confinfo["schedule"] = sched
confinfo["geo"] = maps


infofname, infoext = os.path.splitext(infojson)
outfname = "{}-{}{}".format(infofname, "full", infoext)
print("Saving to {}".format(outfname))
with open(outfname, "w") as wfp:
    json.dump(confinfo, wfp, indent=4)
