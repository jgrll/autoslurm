# autoslurm (as)

 A collection of scripts for generating SLURM job files tailored to your program(s) and computing architecture(s).  Multiple architectures (High Performance Computers) that you have access to can be configured, as well as the various programs you use.

## Features

- **Automated SLURM script generation**: Creates complete job submission scripts from templates
- **Flexible configuration**: Supports multiple clusters, programs, and execution modes
- **Batch processing**: Automatically organizes input files into batches for serial or parallel execution
- **Input file management**: Handles single files or creates subdirectories for multiple inputs
- **Customizable templates**: Easy to extend for new clusters and programs
- **Execution modes**:
  - Serial: Jobs run sequentially within batches
  - Parallel: Each job runs independently in parallel

## Installation

1. Download the project and place the folder wherever you want on your system (e.g., in your `$HOME` or a bin directory included in your `PATH`).

2. Run the installation script  ./install.sh

3. The installer will:
   
   * Create a backup of your `.bashrc` file
   
   * Add the script directory to your PATH
   
   * Notify you if the directory is already in your PATH

After installation, source your `.bashrc` or restart your terminal to apply changes.

```
source ~/.bashrc
```

## Description of the files

- | Script           | Purpose                                                          |
  | ---------------- | ---------------------------------------------------------------- |
  | `as_cfg.sh`      | Generates configuration templates for new clusters/programs      |
  | `as_jobs.sh`     | Main script that processes input files and generates job scripts |
  | `as_header.sh`   | Generates SBATCH directives and module loads                     |
  | `as_body.sh`     | Contains program-specific execution instructions                 |
  | `as_footer.sh`   | Handles post-processing steps                                    |
  | `as_complete.sh` | Assembles complete SLURM scripts (no manual editing needed)      |
  | `install.sh`     | Installation helper                                              |

- **examples/** contains examples of script editing.
  
## Usage

1. Add **your** architecture(s) and program(s) to the scripts.

2. **Prepare your input files**
   - Place input files in one or more directories   
   - Files should have consistent extension (configurable)

3. **Generate configuration file**
  
   ```
   as_jobs.sh
   ```
   This creates a default `job.cfg` file with all available sections.
    * Fill in your cluster details
    * Specify program parameters
    * Set input folders and file extension
    * Choose execution mode (serial/parallel)
    
4.  **Generate job script**

    ```
    as_jobs.sh job.cfg
    ```
    
    The script will:
    - Process input files
    - Create batch files
    - Generate submission scripts
  
5. ****Submit jobs****

    One or more SLURM files have bee created according to the parameters you have chosen.
    Now, tar the current repertory and send it to the computing machine where you will untar it.
    To start the calculations (in case of serial execution) simply run 
  
    ```
    ./launch_serial_all.sh
    ```
    
    All jobs will be submitted.

## How to add an architecture or a program

See the provided examples in the `examples/` folder. You can add support for new computing architectures (clusters) and programs by adding templates to the scripts.

## Examples

To become familiar with editing the scripts to suit your needs, you can refer to the examples provided in the `examples/` directory. In each example, a `data/` folder is included. Each example comes with a pre-filled configuration file, so there is no need to call `as_jobs.sh` without arguments.

To run the examples, copy the content of the folder into the directory added to your `PATH` variable (i.e., the installation directory), and overwrite the existing versions. It is recommended to inspect the modifications made to these scripts before adapting them to your own use case.

### Example 1.1 – Run Jobs in Serial and Prepare Batches

In this example, `as_header.sh` has been modified to include the computing cluster `nest` and to load the required modules for the Quantum ESPRESSO package (program `pw`).

Unlike in Example 2.1, the program's input/output operations can be performed directly in the working directory on this machine, so no file movement is needed. As a result, `as_footer.sh` does not need to be modified. However, `as_body.sh` has been edited to include the specific instructions needed for both `parallel` and `serial` execution modes.

A pre-filled config file is provided, so you can test the execution of `as_jobs.sh` right away. The energy and forces of 100 randomly selected frames from a molecular dynamics trajectory of water are computed using the `pwscf` program. The 100 configurations are initially stored in the same directory. Upon execution, the script creates a dedicated folder for each frame and prepares a SLURM job to execute it.

To speed up the process, the frames are divided into 5 batches of 20 jobs each, which are run in parallel. Within each batch, the frames are computed sequentially.

### Example 1.2 – Adding New Keywords and Parallel Execution

In the previous example, all calculations within a batch were executed one after the other (serial execution), while the batches themselves ran in parallel. In this case, it is possible to run all calculations fully in parallel (one job per frame) by setting `EXECUTION_TYPE=parallel` in the config file. This is equivalent to defining as many batches as there are input files, each executed in serial mode.

If the number of calculations is small, this setting can be used without concern. Note that while the `NBATCH` variable can still be set to a value other than 1, it will have no effect in this mode since all jobs are launched in parallel anyway. Example 1.2 builds on Example 1.1 with the following changes:

1. The number of frames has been reduced to 10 to better illustrate the parallel execution mode.  
2. An additional boolean keyword is set in the config file to enable deletion of large files after the calculation. The Quantum ESPRESSO section of the `as_body.sh` script was updated accordingly.

### Example 2.1 – Adding a New Computing Machine and Program

In this second example, we aim to perform a structural optimization on the 10 configurations from Example 1.2 using a tight-binding model as implemented in `xtb`.  
To add `xtb` to the list of supported programs, it is sufficient to modify the `as_body.sh` script and include the corresponding execution instructions for both `serial` and `parallel` modes. Since `xtb` relies on a simple command-line interface, an additional parameter is introduced in the config file (which is pre-filled and available in the example folder) to define the optimization settings.

In this example, `xtb` is not available on the `nest` machine. A new computing machine named `moon` is therefore added. The architecture of `moon` requires moving files to and from the compute node before and after each calculation, regardless of the program used. As a result, file transfer instructions are added to `as_header.sh` (for staging input files before execution), and to `as_footer.sh` (to retrieve the results afterward).

## Disclaimer

The author of this project is not responsible for any consequences resulting from the use of this script suite in violation of the policies set by your computing center's administration.

Please note that careless use may lead to the submission of a large number of jobs simultaneously, which can
- negatively affect your job priority in the scheduling queue (fair resource usage), 
- prematurely exhaust your allocated computing resources.

## License

This work is protected under the MIT Licence (see LICENCE file).

## Author

[jgrll](https://github.com/jgrll)

Feel free to open an issue or pull request if you have suggestions or encounter a bug.
