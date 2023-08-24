# QSM creation on puhti
## Requirements
- Matlab + required libraries (I used R2022b on a Windows 10 machine)  
- TreeQSM and its scripts added to PATH  
- CSC account added to a project with possibility of running processes on Puhti   
- CSC cluster scripts
  - Downloaded here: https://wiki.eduuni.fi/pages/viewpage.action?spaceKey=cscjemma&title=MATLAB+MPS+configuration
  - Unzip the downloaded package and add the contents to matlab’s path (set path on matlab GUI)
  - After the contents are added to path, you can configure MATLAB to send jobs to puhti with the command below. Then provide your CSC username  
    ``>>configCluster``  
    ``>>Username on Puhti (e.g. joe): yourUsername``
- The segmented trees should be uploaded to puhti before running QSM creation.
  - You will need the folder path to the segmented trees
  - You could also do the segmentation on puhti. I haven’t done that so I’m not sure what’s the best way. To utilise the parallel processing on Puhti you should probably use the tiling approach and run each tile in a separate parallel process.
## Processing  
- To utilise the multiple cores on Puhti, the parallelisation should be done on a separate “parent” script from which you run the QSM scripts.
  - I didn’t get the make_models_parallel.m -script working correctly as is.
  - An example script is provided in this repository (qsm_par_server.m).
    - Make sure to check that the parameters are modified to your needs
- Below is an example of how I would run a large job of processing 296 trees in parallel.
  - The details for the parcluster configurations can be found here https://docs.csc.fi/apps/matlab/ under "Configuring jobs".
  - Since there are over 40 jobs, I'm using the 'large' QueueName.
    - You could also run the job on fewer cores. This will of course increase the runtime, since all of the trees are not being processed simultaneously
  - I'm using the maximum time limit of 72 hours or three days for the 'large' partition
  - More details about the partitions can be found here: https://docs.csc.fi/computing/running/batch-job-partitions/
  - For each node 4g of memory is given, this could possibly be smaller or bigger depending on the tree sizes.
  - Finally I submit the job, the batch parameters being the parcluster (c), the parallel "parent" script (@qsm_par_server), number of outputs (1) and input arguments ({}) (I haven't touched these), pool size (296) (This is the number of cores), the working folder ('/scratch/project_2001208/Eemil') and AutoAddClientPath (false), which I also havent touched.
  - https://www.mathworks.com/help/parallel-computing/batch.html Here you can find the input argument explanations for the batch command.
  - Note that the folder containing the segmented trees in the "parent script" needs to be in line with the working folder in the "batch" commmand. For example, if I have 
 this line in the "parent" script: ``trees = dir('qsm_batch_puhti/*.las');``, then the ``qsm_batch_puhti`` folder need to be located under here ``'/scratch/project_2001208/Eemil'``
  - **You also need to have a "results" folder in your working directory!** e.g. ``/scratch/project_2001208/Eemil/results/``, otherwise your run will probably terminate

``>>c = parcluster;``  
``>>c.AdditionalProperties.QueueName = 'large';  ``  
``>>c.AdditionalProperties.WallTime = '72:00:00';  ``  
``>>c.AdditionalProperties.MemUsage = '4g';  ``  
``>>j = batch(c, @qsm_par_server, 1,{}, 'Pool',296, 'CurrentFolder','/scratch/project_2001208/Eemil','AutoAddClientPath', false);``  

You should now be able to find your job on the Puhti dashboard, It might take some time for it to start processing. From my experience, checking the status via matlab is unreliable.


- If you processed a large amount of trees, the results can be a little hard to download, however you can zip them by going to your directory in puhti dashboard, clicking on the "Open in terminal button" and typing  ``find results/ -type f -mtime -7 -exec zip -r results.zip {} \;`` where results is the directory where you have your QSM results and results.zip is the destination zip file.
