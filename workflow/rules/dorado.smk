rule dorado_basecall:
    input:
        pod5=lambda wc: sample_pod5(wc.sample),
    output:
        fastq="results/dorado/{sample}/{sample}.fastq",
    log:
        "logs/dorado/{sample}.log",
    conda:
        "../envs/python.yaml"
    container:
        lambda wc, output, params: (
            params.docker_image if params.exec_mode == "docker" else None
        )
    threads: config["threads"]
    params:
        model=config["dorado"]["model"],
        extra=config["dorado"].get("extra_params", "--estimate-poly-a"),
        docker_image=config["dorado"].get("docker_image", ""),
        exec_mode=config["exec_mode"],
    shell:
        """
        mkdir -p "$(dirname {output.fastq})" "$(dirname {log})"
        dorado basecaller {params.model} {input.pod5} {params.extra} >{output.fastq} 2>>{log}
        test -s {output.fastq}
        """
