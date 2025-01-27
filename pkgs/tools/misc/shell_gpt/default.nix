{ lib
, python3
, fetchPypi
, nix-update-script
}:

python3.pkgs.buildPythonApplication rec {
  pname = "shell_gpt";
  version = "0.9.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-k57oPqUpBuqoJFJ2JU3O4d4ESqb1DqJam/L+lJgBWIQ=";
  };

  nativeBuildInputs = with python3.pkgs; [
    python3.pkgs.pythonRelaxDepsHook
    python3
    pip
  ];

  propagatedBuildInputs = with python3.pkgs; [
    markdown-it-py
    rich
    distro
    typer
    requests
    hatchling
  ];

  pythonRelaxDeps = [ "requests" "rich" "distro" "typer" ];

  passthru.updateScript = nix-update-script { };

  doCheck = false;

  meta = with lib; {
    mainProgram = "sgpt";
    homepage = "https://github.com/TheR1D/shell_gpt";
    description = "Access ChatGPT from your terminal";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ mglolenstine ];
  };
}
