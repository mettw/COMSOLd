# COMSOLd
Daemon for controling COMSOL jobs

# Installation
1) Copy the directory User_dir_example/ to wherever you want to store your job scripts and other supporting MATLAB files.  MATLAB has an online drive like OneDrive available that is a convenient place for it.

2) Edit the file get_user_dirs.mlx so that your new location for the user directory is listed.  This is the list of users' directories that COMSOLd will search for jobs and support functions.  You can add more than one user directory if you want.

3) Create a COMSOL model file.  Importantly, in the results node there is an 'export' sub-node that you need to populate with nodes - one for each result that you want to export.  Suppose that you have created a "Global Evaluation" called "Parameters" at
results->Derived Values- >Parameters
which outputs to 
results->Tables->tbl33
For convenience rename it to something like
results->Tables->Parameters
You then create a table export node like
results->export->Parameters
and make it point to results->Tables->Parameters.  In the option for a filename *don't* write the full path to a file, instead just write what you want the file to be called.  eg, just enter "parameters.txt".  COMSOLd will automatically save it to the correct directory.  Do this for every possible result that you might want to export, regardless of whether or not you might want to export it for some particular job.  You can alter which get exported and which don't in the jobscript.

4) (i) In your user directory there is a sub-directory called jobs/ which is where you put all of the job scripts that you want to run.  They are run in order of age.  If you want to run a new script before the others in the queue then put it in the jobs/priority/ directory.  All of the scripts in that directory will be run before running those in the jobs/ directory.  When a job script is selected to run it is moved to the COMSOLd/running/ directory so that you can have more than one instance of COMSOLd running without them trying to run the same script.  When the job is successfully completed the job script is moved to the jobs/completed/ directory.

   (ii) In your user directory there are some support files:
      * mph_description_auto.mlx - This is a new file, but hopefully it works well.  Once COMSOLd opens the model file it will call this file (or any other you want, it is a configurable option) to create a set of tables describing the model file that allows you to describe what changes to make and what to export.
      * postpro.mlx - If the postprocessing stage (after all of the data has been exported) fails then you can use this script to rerun it for a particular job.
      * rm_mat_files.mlx - deletes all of the matlab files generated in the postprocessing stage for the job specified in the mlx file.
      * shutdown.mlx - put a copy of this in the jobs/ directory to shut down COMSOLd when it is run.
      * user_post_processing.mlx - This is my postprocessing function.  I tried to make it as general as possible, so it should work for you as well.
      * set_default_options_auto.mlx - This is where you edit the matlab tables created by mph_description_auto.mlx so that you can change parameter values and what to export (by default nothing is exported).  It would take a while to explain what is going on here.  It might be usefull to set a breakpoint at the start of the file and try playing around with the MATLAB tables so that you can get an idea of how they work.

   (iii) In the jobs directory there is a file called example_job_script.mlx which is exactly what the name suggests. Edit the directories and names to reflect the layout of your computer.

5) run the script start_comsold.mlx in the MATLAB command line (If you try to run it by pressing the green arrow then it won't work).
