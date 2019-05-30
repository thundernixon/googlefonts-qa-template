# Template files for Google Fonts QA & Variable Font upgrades

This is a work-in-progress repo to document some useful techniques, scripts, and workflows in quality assurance (QA) and variable-font upgrades for Google Fonts projects. It seeks to document and save lessons learned from projects including Inter, Fira Code, Merriweather, Encode Code, and Maven Pro, and more.

Scripts are written with the assumption of running on macOS.

## Overall process

1. Move the `sources/build.sh` script into your project's `source` folder
2. Update first line of OFL to fit your font project (you may already have this)
3. Use build process (below) to setup dependencies & build fonts
4. Duplicate the `googlefonts-qa` folder into your project. Update these scripts and run as needed.

## Build Process

The sources can be built with FontMake, but I've put together some specific build scripts to pass the fonts through some steps that fix metadata issues.

### Step 1: Set up the project locally

The build process requires you to open up a terminal and navigate to the current project's directory. Open a terminal, then navigate to the a directory (folder) for type projects, and git clone this repo.

```bash
cd path/to/your_type_repos_directory/current_project

# git clone the project if you don't already have it
```

You should use a Python virtual environment to build this project. If you've never set up a virtual environment before, [read more about it in this guide](https://packaging.python.org/tutorials/installing-packages/#creating-virtual-environments).

You can set up a Python 3 virtual environment with:

```bash
python3 -m venv ./venv
```

Here, `python3 -m venv` calls the virtual-environment-making module, then the `./venv` gives it a path to setup a virtual environment in (you could give a different path, but this is a conventional name).

Before you install dependencies or run the build, you need to activate the virtual environment with:

```bash
source venv/bin/activate
```

If you wish exit out of the virtual environment, you can use the command `deactivate` (just remember to start it up again if you come back). You can also simply close the terminal session.

Once you've activated the venv, install requirements by pointing pip to the `requirements.txt` file:

```bash
pip install -r requirements.txt
```

Note: right now, gftools [may give you some installation issues](https://github.com/googlefonts/gftools/issues/121). This most likely will require you to install some other specific requirements on your computer and/or in the virtual environment. I would provide more detail, but I don't fully understand it right now.

### Step 2: Give permissions to build scripts

The first time you run the build, you will need to give run permissions to the build scripts.

On the command line, from the project folder, and then give permissions to the build script with:

```bash
chmod +x sources/build.sh
```

To use the other scripts, you must also give them permissions to run.

Using `chmod +x` gives shell scripts execute permissions. In general, before you do this for shell scripts, you should probably take a look through their contents, to be sure they aren't doing anything you don't want them to do. The ones in this repo simply build from the GlyphsApp sources and apply various fixes to the results.

### Step 3: Edit & run the build scripts!

Update the variables in each of the scripts you wish to run.

Then, run the build script (or any of the others) by entering its relative path in your terminal:

```bash
sources/build.sh
```

## Check process

### FontBakery

Run `googlefonts-qa/check.py` to produce FontBakery checks.

### Diffing fonts against existing versions on Google Fonts

1. Download existing fonts from Google Fonts (or git clone the entire google/fonts repo)
2. Follow the [Installation](https://github.com/googlefonts/fontdiffenator#installation) and [Usage](https://github.com/googlefonts/fontdiffenator#usage) instructions in googlefonts/diffenator.
