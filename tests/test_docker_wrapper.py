import unittest

from workflow.scripts import docker_wrapper as dw


class TestDockerWrapper(unittest.TestCase):
    def test_command_building(self):
        image = "quay.io/biocontainers/samtools:1.23--h96c455f_0"
        volumes = ["/host:/host"]
        workdir = "/host"
        cmd = ["bash", "-lc", "echo", "ok"]
        built = dw.build_docker_command(image, volumes, workdir, cmd)
        self.assertEqual(built[0], "docker")
        self.assertIn(image, built)

    def test_apptainer_command_building(self):
        image = "docker://quay.io/biocontainers/samtools:1.23--h96c455f_0"
        built = dw.build_apptainer_command(
            image, "/host:/host", "/host", ["samtools", "--version"]
        )
        self.assertEqual(built[0], "apptainer")
        self.assertEqual(built[1], "exec")

    def test_native_and_conda(self):
        cfg = {
            "exec_mode": "native",
            "minimap2": {"minimap2_bin": "/opt/minimap2", "docker_image": ""},
        }
        prefix, binary = dw.docker_wrapper_binary(
            cfg, "minimap2", "minimap2_bin", "minimap2"
        )
        self.assertEqual(prefix, "")
        self.assertEqual(binary, "/opt/minimap2")
        cfg["exec_mode"] = "conda"
        prefix, binary = dw.docker_wrapper_binary(
            cfg, "minimap2", "minimap2_bin", "minimap2"
        )
        self.assertEqual(binary, "minimap2")

    def test_invalid_mode(self):
        with self.assertRaises(ValueError):
            dw.docker_wrapper_binary(
                {"exec_mode": "podman", "minimap2": {}},
                "minimap2",
                "minimap2_bin",
                "minimap2",
            )


if __name__ == "__main__":
    unittest.main()
