import json
from pathlib import Path

path = Path("logs/transcript.jsonl")
if not path.exists():
    print("# Transcript\n\nNo transcript found.")
    raise SystemExit(0)

print("# Transcript\n")
for line in path.read_text(encoding="utf-8").splitlines():
    if not line.strip():
        continue
    obj = json.loads(line)
    print(f"## Turn {obj.get('turn')} | {obj.get('type')}")
    print(f"- Time: {obj.get('ts')}")
    print(f"- From: {obj.get('from')}")
    print(f"- To: {obj.get('to')}")
    print()
    print(obj.get("content", ""))
    print()
