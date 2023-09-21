function t = qsm_par_server
t = [];
% List the tree point cloud files, replace the folder with yours
trees = dir('qsm_batch_puhti/*.las');
% This is where the parallellisation happens, with the parfor-command
parfor i = 1:length(trees)
    % Create the point cloud path
    path = [trees(i).folder,'/',trees(i).name];
    % Read the las file with lasFileReader
    lasReader = lasFileReader(path);
    % Create a point cloud
    ptCloud = readPointCloud(lasReader);
    P = ptCloud.Location;

    % Normalise the point cloud coordinates
    %Center = mean(P);
    % Here I have a center point that I subtracted from all of the trees
    Center = [306211.2431640625, 5695182.041666667, 95.88448810572918];
    Q = P - Center;
    % Change the individual tree cloud type so that it works with the QSM
    % tools
    Q = mat2cell(Q, length(Q), 3);
    % Define inputs and filter the tree cloud, modify these based on your
    % needs
    inputs = define_input(Q,2,3,2);
    inputs.filter.plot = 0;
    inputs.plot = 0;
    inputs.disp = 1;
    Q = filter_trees(Q, inputs);
    % Format output
    formatSpec = strrep(trees(i).name, '.las', '');
    % Create models
    QSM = make_models(Q, formatSpec, 5, inputs);
    % Format optimal output
    formatSpec = [formatSpec, '_opt'];
    % Select optimal model and save it
    [TreeData,OptModels,OptInputs,OptQSM] = select_optimum(QSM,'trunk+1branch',formatSpec);
    % save_model_text(OptQSM,formatSpec, Center); -- This is for a slightly
    % modified version of the save_model_text.m which additionally outputs the trunk
    % base coordinates 
    save_model_text(OptQSM,formatSpec)
end
end
