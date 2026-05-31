# Library Directory Audit Report

## Summary
This report classifies files in `library/` by whether they are still reachable
from any entry-point script in the repo. It was **re-verified empirically** by
scanning every `.py` file (excluding `venv/`) for inbound import references and
following the dependency graph transitively — not by architecture name alone.

> ⚠️ The previous version of this audit was inaccurate: it listed several files
> as "safe to delete" that are in fact imported (e.g. `sd3_train_utils.py` is
> imported by `anima_train_utils.py`, and the SDXL/Lumina/Flux helper files are
> used by the SDXL and Lumina trainers). Always confirm with a reference scan
> before deleting.

## Removed (confirmed dead, deleted)
These formed isolated dead subgraphs: nothing outside the group imported them.

### Hunyuan (entire subgraph — self-contained, no external importers)
- `library/strategy_hunyuan_image.py`
- `library/hunyuan_image_models.py`
- `library/hunyuan_image_modules.py`
- `library/hunyuan_image_text_encoder.py`
- `library/hunyuan_image_utils.py`
- `library/hunyuan_image_vae.py`

### Unused strategy shims (no inbound references)
- `library/strategy_sd3.py`  (note: `sd3_models.py`, `sd3_utils.py`, `sd3_train_utils.py` are **kept** — used by Anima/Lumina/Flux)
- `library/strategy_flux.py` (note: `flux_models.py`, `flux_utils.py` are **kept** — referenced elsewhere)

## Still referenced — DO NOT DELETE
Verified to have live inbound references (reference count in parentheses):

- `sd3_models.py` (17), `sd3_train_utils.py` (7), `sd3_utils.py` (6) — used by Anima/Lumina/Flux paths
- `strategy_lumina.py` (20), `lumina_models.py` (18), `lumina_train_util.py` (19), `lumina_util.py` (15) — used by `lumina_train*.py`
- `flux_models.py` (23), `flux_utils.py` (7) — `flux_utils` also pulls in `chroma_models.py`
- `strategy_sdxl.py` (12), `sdxl_model_util.py` (31), `sdxl_original_unet.py` (33), `sdxl_train_util.py` (28),
  `sdxl_lpw_stable_diffusion.py` (3), `sdxl_original_control_net.py` (3) — used by `sdxl_train*.py` / `sdxl_gen_img.py`
- `slicing_vae.py` (1) — used by `sdxl_gen_img.py`
- `hypernetwork.py` (6), `original_unet.py` (9), `lpw_stable_diffusion.py` (4), `chroma_models.py` (2)

## Possible future cleanup (dead, but left in place for now)
- `library/flux_train_utils.py` — the only inbound reference is a *comment* in
  `lumina_train_util.py` ("mainly copied from flux_train_utils..."); no real
  import. Safe to delete, kept for now to avoid surprising users.
- The non-Anima entry scripts (`fine_tune.py`, `sdxl_train*.py`, `sdxl_gen_img.py`,
  `lumina_*.py`) are out of scope for an "Anima LoRA-only" trainer. Removing them
  would also free their exclusive `library/` dependencies — but this is a product
  decision, not a pure cleanup, so it is intentionally left to the maintainer.

## Critical Files (core — never delete)
- `library/strategy_sd.py` — required by `train_network.py` (parent of `AnimaNetworkTrainer`)
- `library/train_util.py` — core utility library
- `library/anima_*.py` — core Anima files
- `library/fp8_optimization_utils.py` — used by `lora_utils.py`

## How to re-verify
```bash
# For a module name, list inbound references across the repo (excluding venv):
grep -rnE "\bMODULE_NAME\b" --include=*.py . | grep -v "/venv/" | grep -v "library/MODULE_NAME.py:"
```
A module is safe to delete only if it has zero references, or its only references
come from other files that are themselves dead (an isolated dead subgraph).
