# Unreal previs pack import — run in Unreal's Python console (Editor Scripting).
# Batch-imports every asset in this pack under /Game/Previs/<PackId>/, with Nanite
# enabled ONLY on the hero pieces (previs wants dense heroes + light dressing that
# the DP can instance freely). Pack layout: assets/<prop_id>/model.(fbx|glb).
#
# SCALE (F93, ENGINE-VERIFIED in UE 5.8, 2026-07-10): the shipped FBX declares
# METERS (UnitScaleFactor=100) while vertex magnitudes are mm, so UE's default
# import lands every prop 1000x oversized (a 4.2 m cannon imports at 4.2 km).
# import_uniform_scale = 0.001 corrects to true real-world size (1 uu = 1 cm).
# ORIENTATION (F97): props whose source mesh lies down carry a per-asset
# "import_rotation" [roll,pitch,yaw] in the manifest; applied at import.
# Root fix (export true-cm, upright-baked FBX) queued — this contract makes the
# CURRENT exports land correctly.
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
        # F93 (UE-5.8-verified): FBX declares meters but verts are mm-magnitude ->
        # default import is 1000x oversized; 0.001 lands true size (1 uu = 1 cm).
        opts.static_mesh_import_data.import_uniform_scale = 0.001
        rot = asset.get("import_rotation")
        if rot:  # F97: stand up lying source meshes (manifest-driven)
            opts.static_mesh_import_data.import_rotation = unreal.Rotator(
                roll=float(rot[0]), pitch=float(rot[1]), yaw=float(rot[2]))
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
