# Template project for ssdd-lab

This repository is a Python project template. It contains the
following files and directories:

- `config` has several configuration files examples, including needed
  IceStorm configuration files.
- `iceflix` is the main Python package. You could rename it to
  something meaninful for your project.
- `iceflix/__init__.py` is an empty file needed by Python to
  recognise the `packagename` directory as a Python package/module.
- `iceflix/cli.py` contains several functions that can handle the
  basic console entry points defined in `python.cfg`. The name of the
  submodule and the functions can be modified if you need.
- `iceflix/iceflix.ice` contains the Slice interface definition for
  the project.
- `iceflix/main.py` has a minimal implementation of a service, without
  the service servant itself. Can be used as template for main or other
  services.
- `iceflix/rtsputils.py` contains the classes for RTSP emitter and
  player using Gstreamer and VLC respectively.
- `iceflix/service_announcement.py` contains the needed classes for
  service announcement events reception and sending.
- `pyproject.toml` defines the build system used in the project.
- `run_client` should be a script that can be run directly from the
  repository root directory. It should be able to run the IceFlix
  client.
- `run_iceflix` should be a script that can be run directly from the
  repository root directory. It should be able to run all the services
  in background in order to test the whole system.
- `setup.cfg` is a Python distribution configuration file for
  Setuptools. It needs to be modified in order to adeccuate to the
  package name and console handler functions.
