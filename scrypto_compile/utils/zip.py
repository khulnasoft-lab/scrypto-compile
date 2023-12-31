"""
Handle ZIP operations
"""
import json
import zipfile

# Cycle dependency
from typing import TYPE_CHECKING, List, Union
from zipfile import ZipFile

from scryto_compile.platform.archive import generate_archive_export

if TYPE_CHECKING:
    from scryto_compile import ScrytoCompile


def _to_str(txt: Union[bytes, str]) -> str:
    """Convert bytes to an utf8 str. Do nothing if its already a str

    Args:
        txt (Union[bytes, str]): target name

    Returns:
        str: str
    """
    if isinstance(txt, bytes):
        return txt.decode("utf8")
    return txt


def load_from_zip(target: str) -> List["ScrytoCompile"]:
    """Load a file from a zip

    Args:
        target (str): path to the file

    Returns:
        List[ScrytoCompile]: List of loaded projects
    """
    # pylint: disable=import-outside-toplevel
    from scryto_compile import ScrytoCompile

    compilations = []
    with ZipFile(target, "r") as file_desc:
        for project in file_desc.namelist():
            compilations.append(
                ScrytoCompile(_to_str(file_desc.read(project)), compile_force_framework="Archive")
            )

    return compilations


# https://docs.python.org/3/library/zipfile.html#zipfile-objects
ZIP_TYPES_ACCEPTED = {
    "lzma": zipfile.ZIP_LZMA,
    "stored": zipfile.ZIP_STORED,
    "deflated": zipfile.ZIP_DEFLATED,
    "bzip2": zipfile.ZIP_BZIP2,
}


def save_to_zip(
    scryto_compiles: List["ScrytoCompile"], zip_filename: str, zip_type: str = "lzma"
) -> None:
    """Save projects to a zip

    Args:
        scryto_compiles (List[ScrytoCompile]): List of project to save
        zip_filename (str): zip filename
        zip_type (str): Zip types. Supported lzma, stored, deflated, bzip2. Defaults to "lzma".
    """
    with ZipFile(
        zip_filename, "w", compression=ZIP_TYPES_ACCEPTED.get(zip_type, zipfile.ZIP_LZMA)
    ) as file_desc:
        for scryto_compile in scryto_compiles:
            output, target_name = generate_archive_export(scryto_compile)
            file_desc.writestr(target_name, json.dumps(output))
