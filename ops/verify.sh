#!/usr/bin/env bash
# verify.sh: Parashakti's own gate. The scripts parse, the engine compiles, and the manifest is sound.
cd "$(dirname "$0")/.."; f=0
bash -n parashakti.sh && echo "  PASS  parashakti.sh parses" || { echo "  FAIL  parashakti.sh parses"; f=1; }
bash -n parashakti_docker.sh && echo "  PASS  parashakti_docker.sh parses" || { echo "  FAIL  parashakti_docker.sh parses"; f=1; }
python3 - <<'PY' || f=1
import re
s = open("parashakti.sh", encoding="utf-8").read(); e = s[s.index("<<'ENGINE'") + 10:s.rindex("\nENGINE")]
compile(e, "engine", "exec"); print("  PASS  the engine compiles")
names = re.findall(r'^  "([a-z0-9.\-]+)": \{"needs"', e, flags=re.M)
assert names and names[0] == "shakti-sdk", names[:3]; print(f"  PASS  the manifest: {len(names)} projects, the SHAKTI SDK first")
PY
exit $f
