function t = qsm_par_server_test2
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
    % Here I have a general center point that I subtracted from all of the
    % trees, replace this with your own, this was from Leipzig area in
    % Germany
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
    str = sprintf(formatSpec,i);
    % Create models
    QSM = make_models(Q, str, 5, inputs);
    % Format optimal output
    formatSpec = [formatSpec, '_opt'];
    str = sprintf(formatSpec,i);
    % Select optimal model and save it
    [TreeData,OptModels,OptInputs,OptQSM] = select_optimum(QSM,'trunk+1branch+hbranch_mean_dis',formatSpec);
    t = [t, OptQSM];
    save_model_text(OptQSM,str, Center);
end
end