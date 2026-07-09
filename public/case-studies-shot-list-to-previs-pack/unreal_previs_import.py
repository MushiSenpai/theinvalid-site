# Unreal previs pack import — run in Unreal's Python console (Editor Scripting).
# Batch-imports every asset in this pack under /Game/Previs/<PackId>/, with Nanite
# enabled ONLY on the hero pieces (previs wants dense heroes + light dressing that
# the DP can instance freely). Pack layout: assets/<prop_id>/model.(fbx|glb).
#
# SCALE: meshes are authored at the mm spec (1 unit = 1 mm); this import scales
# mm->cm (import_uniform_scale = 0.1) so props land at true real-world size in UE
# (1 uu = 1 cm). Without it, everything imports 10x too large (F93, 2026-07-09).
#
# This script is generated from pack_manifest.json — edit the pack, re-export, and
# re-run; it is idempotent (replace_existing=True).
import unreal, os, json

PACK_DIR = os.path.dirname(os.path.abspath(__file__))
DEST_ROOT = "/Game/Previs/shotpack-previs-20260705-024756"

with open(os.path.join(PACK_DIR, "pack_manifest.json")) as f:
    PACK = json.load(f)

tools = unreal.AssetToolsHelpers.get_asset_tools()
imported = []
for asset in PACK["assets"]:
    if asset.get("status") != "delivered":
        print("skip (not delivered):", asset["prop_id"], "-", asset.get("park_reason"))
        continue
    fbx = asset.get("fbx") or asset.get("glb")
    if not fbx:
        print("skip (no mesh file):", asset["prop_id"]); continue
    src = os.path.join(PACK_DIR, fbx)
    dest = DEST_ROOT + "/" + asset["prop_id"]
    task = unreal.AssetImportTask()
    task.filename = src
    task.destination_path = dest
    task.automated = True
    task.replace_existing = True
    if src.lower().endswith(".fbx"):
        opts = unreal.FbxImportUI()
        opts.import_mesh = True
        opts.import_as_skeletal = False
        opts.import_materials = True
        opts.static_mesh_import_data.build_nanite = bool(asset.get("nanite"))
        opts.static_mesh_import_data.generate_lightmap_u_vs = False
        opts.static_mesh_import_data.import_uniform_scale = 0.1  # mm->cm (F93)
        task.options = opts
    tools.import_asset_tasks([task])
    for a in task.imported_object_paths:
        m = unreal.load_asset(a)
        if isinstance(m, unreal.StaticMesh) and asset.get("nanite"):
            ns = m.get_editor_property("nanite_settings"); ns.enabled = True
            m.set_editor_property("nanite_settings", ns)
            unreal.EditorAssetLibrary.save_loaded_asset(m)
    imported += list(task.imported_object_paths)
print("Previs pack import complete: %d asset(s) under %s" % (len(imported), DEST_ROOT))
