#!/usr/bin/env python3
"""Generate nf-core module templates from schemas/variants.json and schemas/categories.json."""

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCHEMAS = ROOT / "schemas"
TEMPLATES = ROOT / "templates"

STORAGE_ABBR = {"monolithic": "Mono", "chunked": "Chnk"}
OUTPUT_ABBR = {
    "image": "Img", "mask": "Msk", "vector": "Vec", "tabular": "Tab",
    "scalar": "Scl", "skeleton": "Skl", "swc": "SWC", "track": "Trk",
    "track+div": "TrkDiv", "points": "Pts", "classmask": "ClsMsk",
}
PARALLEL_ABBR = {"external": "Ext", "internal": "Int"}
PROFILE_ABBR = {"enduser": "EU", "developer": "Dev"}

OUTPUT_SUFFIX = {
    "image": "_processed.tif", "mask": "_labels.tif", "vector": "_labels.geojson",
    "tabular": "_features.csv", "scalar": "_counts.csv", "skeleton": "_skeleton.tif",
    "swc": "_trace.swc", "track": "_tracks.csv", "track+div": "_tracks/",
    "points": "_detections.csv", "classmask": "_landmarks.csv",
}


def load_json(name):
    with open(SCHEMAS / name) as f:
        return json.load(f)


def abbr_name(cat, v):
    return (
        f"{cat['id']}_{STORAGE_ABBR[v['storage']]}_{OUTPUT_ABBR[v['output']]}"
        f"_{PARALLEL_ABBR[v['parallelism']]}_{PROFILE_ABBR[v['user_profile']]}"
    )


def full_name(cat, v):
    axes = load_json("axes.json")
    s = axes["storage"][v["storage"]]["full"]
    o = axes["output"][v["output"]]["full"]
    p = axes["parallelism"][v["parallelism"]]["full"]
    u = axes["user_profile"][v["user_profile"]]["full"]
    return f"{cat['full_name']}_{s}_{o}_{p}_{u}"


def version_cmd(v):
    tool = v["category_id"].lower()
    if v["ecosystem"] == "python":
        return f"python -m {tool} --version 2>&1 | sed 's/.*//g'"
    return f"fiji --headless --eval 'println(System.getProperty(\"fiji.version\"))' 2>&1 | tail -1"


def process_label(v):
    if v["gpu"] == "required":
        return "process_gpu"
    if v["gpu"] == "optional":
        return "process_medium"
    if v["parallelism"] == "internal":
        return "process_high"
    return "process_medium"


def gen_script_body(v):
    tool = v["category_id"].lower()
    io = v["io_strategy"]
    model = v["model"]
    lines = [
        'def args = task.ext.args ?: \'\'',
        'def prefix = task.ext.prefix ?: "${meta.id}"',
    ]

    if v["storage"] == "monolithic":
        cmd = f"python -m {tool}" if v["ecosystem"] == "python" else f"fiji --headless --run {tool}.groovy"
        input_flag = "$image" if "image" in v["nf_input"] else (
            "$labels" if "labels" in v["nf_input"] else "$image"
        )
        lines.append('"""')
        lines.append(f"{cmd} \\\\")
        lines.append(f"    --input {input_flag} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append(f"    --output ${{prefix}}{OUTPUT_SUFFIX.get(v['output'], '_output.txt')} \\\\")
        lines.append("    $args")
        lines.append('"""')
    elif io == "new_group_same_zarr":
        lines.append('"""')
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append("    --output-group processed \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')
    elif io in ("new_zarr_symlink_labels", "new_zarr_symlink_meta"):
        suffix = "_seg" if "Seg" in v["category_id"] else "_out"
        lines.append(f'def out_zarr = "${{prefix}}{suffix}.zarr"')
        lines.append('"""')
        lines.append("python -c \"")
        lines.append("import os; from pathlib import Path")
        lines.append("src, dst = Path('${zarr_dir}'), Path('${out_zarr}')")
        lines.append("dst.mkdir(exist_ok=True)")
        lines.append("for item in src.iterdir():")
        lines.append("    if item.name != 'labels': os.symlink(item.resolve(), dst / item.name)")
        lines.append('"')
        lines.append("")
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append("    --output-zarr ${out_zarr} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')
    else:  # read_only_new_file
        lines.append('"""')
        lines.append(f"python -m {tool} \\\\")
        lines.append("    --input-zarr ${zarr_dir} \\\\")
        lines.append(f"    --output ${{prefix}}{OUTPUT_SUFFIX.get(v['output'], '_output.txt')} \\\\")
        if model == "model_input":
            lines.append("    --model ${model_weights} \\\\")
        lines.append("    $args")
        lines.append('"""')

    return "\n    ".join(lines)


def gen_stub_body(v):
    suffix = OUTPUT_SUFFIX.get(v["output"], "_output.txt")
    return f'''def prefix = task.ext.prefix ?: "${{meta.id}}"
    """
    touch ${{prefix}}{suffix}
    """'''


def gen_main_nf(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    tool = v["category_id"].lower()
    eco = v["ecosystem"]
    label = process_label(v)
    vcmd = version_cmd(v)

    conda_pkg = f"bioconda::{tool}=1.0.0" if eco == "python" else f"bioconda::fiji-{tool}=1.0.0"
    container_base = tool if eco == "python" else f"fiji-{tool}"

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

process {pname} {{
    tag "$meta.id"
    label '{label}'

    conda "{conda_pkg}"
    container "${{ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/{container_base}:1.0.0--pyhdfd78af_0' :
        'biocontainers/{container_base}:1.0.0--pyhdfd78af_0' }}"

    input:
    {v['nf_input']}

    output:
    {v['nf_output']}
    tuple val("${{task.process}}"), val('{tool}'), eval('{vcmd}'), emit: versions_{tool}, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    {gen_script_body(v)}

    stub:
    {gen_stub_body(v)}
}}
"""


def gen_meta_yml(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    tool = v["category_id"].lower()
    vcmd = version_cmd(v)

    input_section = ""
    if v["storage"] == "chunked":
        input_section += """  - zarr_dir:
      type: directory
      description: Path to OME-Zarr directory
      pattern: "*.zarr"
"""
    elif "geojson" in v["nf_input"]:
        input_section += """  - geojson:
      type: file
      description: Vector annotation file
      pattern: "*.{geojson,wkt}"
"""
    else:
        input_section += """  - image:
      type: file
      description: Input image file
      pattern: "*.{tif,tiff,png}"
"""
    if v["model"] == "model_input":
        input_section += """  - model_weights:
      type: file
      description: Path to model weights file
      pattern: "*.{pth,h5,onnx,pt}"
"""

    return f"""# Full name:    {fname}
# Abbreviation: {aname}

name: "{aname.lower()}"
description: |
  {cat['task']}
  Storage: {v['storage']} | User profile: {v['user_profile']}
keywords:
  - bioimage
  - {tool}
  - {v['storage']}
  - {v['output']}
tools:
  - "{tool}":
      description: "{cat['task']}"
      homepage: "https://github.com/example/{tool}"
      documentation: "https://github.com/example/{tool}/docs"
      licence: ["MIT"]
input:
  - meta:
      type: map
      description: |
        Groovy map containing sample metadata.
        e.g. [id: 'sample1', pixel_size_xy: 0.65, pixel_size_z: 2.0]
{input_section}output:
  - meta:
      type: map
      description: Groovy map containing sample metadata
topics:
  versions:
    - - "${{task.process}}":
          type: string
          description: The name of the process
      - "{tool}":
          type: string
          description: The name of the tool
      - "{vcmd}":
          type: eval
          description: The command used to obtain the version of the tool
"""


def gen_test(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    data_key = "zarr" if v["storage"] == "chunked" else "image"
    model_line = ""
    if v["model"] == "model_input":
        model_line = ",\n                    file(params.test_data['model'], checkIfExists: true)"

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

nextflow_process {{
    name "Test {pname}"
    script "../main.nf"
    process "{pname}"

    test("Should run {cat['id']} {v['storage']} {v['user_profile']}") {{
        when {{
            process {{
                \"\"\"
                input[0] = [
                    [id: 'test', pixel_size_xy: 0.65],
                    file(params.test_data['{data_key}'], checkIfExists: true){model_line}
                ]
                \"\"\"
            }}
        }}
        then {{
            assertAll(
                {{ assert process.success }},
                {{ assert snapshot(process.out).match() }},
                {{ assert process.out.findAll {{ key, val -> key.startsWith('versions') }} }}
            )
        }}
    }}
}}
"""


def gen_modules_config(cat, v):
    aname = abbr_name(cat, v)
    fname = full_name(cat, v)
    pname = aname.upper()
    params = v.get("params", "")
    param_comments = "\n            ".join(f"// {p.strip()}" for p in params.split(",") if p.strip())

    return f"""// Full name:    {fname}
// Abbreviation: {aname}

process {{
    withName: '{pname}' {{
        ext.args = [
            {param_comments}
        ].join(' ')
        publishDir = [
            path: {{ "${{params.outdir}}/{cat['id'].lower()}" }},
            mode: params.publish_dir_mode,
            saveAs: {{ filename -> filename.equals('versions.yml') ? null : filename }}
        ]
    }}
}}
"""


def main():
    categories = {c["id"]: c for c in load_json("categories.json")}
    variants = load_json("variants.json")

    for v in variants:
        cat = categories[v["category_id"]]
        storage = v["storage"]
        profile = v["user_profile"]

        out_dir = TEMPLATES / storage / profile / cat["id"].lower()
        out_dir.mkdir(parents=True, exist_ok=True)
        test_dir = out_dir / "tests"
        test_dir.mkdir(exist_ok=True)

        (out_dir / "main.nf").write_text(gen_main_nf(cat, v))
        (out_dir / "meta.yml").write_text(gen_meta_yml(cat, v))
        (test_dir / "main.nf.test").write_text(gen_test(cat, v))
        (out_dir / "modules.config").write_text(gen_modules_config(cat, v))

        print(f"  ✓ {out_dir.relative_to(ROOT)}")

    print(f"\nGenerated templates for {len(variants)} variants.")


if __name__ == "__main__":
    main()
