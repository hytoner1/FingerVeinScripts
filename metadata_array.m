classdef metadata_array
    %{
    Object for storing metadata of the images (refer to image_metadata
    class) in an ordered manner.
    Initialised given the directory containing folders with images for
    given participant, where the name of the folder is the participant's id
    number.
    
    Properties:
        - images - Map Containers object. Keys of the object are character
        vectors of participant id number (= respective folder name). Each
        entry of 'images' object is a 6x4 cell array, with 6 rows
        corresponding to finger id numbers and 4 columns - for consecutive
        measurements. Cells of the cell array store image_metadata objects
        for each of the images.
        - fingers - 6x1 cell array containing names of the fingers accepted
        as an alternative to numeric finger id in get_image and get_fname
        methods.
    
    Methods:
        - obj = metadata_array(directory) - constructor method.
        - im_fname = get_fname(obj, varargin) - returns name of the image
        file for given participant, finger, and measurement.
        - image = get_image(obj, varargin) - returns image_container object -
        image with the associated metadata.
    %}
    properties
        images
        fingers
    end
    
    methods
        function obj = metadata_array(datapath)
            % Constructor method.
            % Create metadata_array object from given directory (character
            % array).
            
            % get list of subdirectoriesisub
            
            directory = dir(datapath);
            isub = [directory(:).isdir];
            datafolders = {directory(isub).name};
            datafolders(ismember(datafolders,{'.','..'})) = [];
            
            obj.images = containers.Map; % create Map Containers object
            
            for idx = 1:numel(datafolders) %for each subfolder = participant
                p = char(datafolders(idx)); %p: folder name = participant id
                images_p = imageDatastore(fullfile(['images/' p])); % all images from p
                p_cell = cell(6,4); % cell array for given participant: 6 fingers, 4 measurements
                for im_idx =1:numel(images_p.Files)
                    im_meta = image_metadata(images_p.Files(im_idx));
                    p_cell(im_meta.finger_id, im_meta.measurement_id) = {im_meta};
                end
                obj.images(p) = p_cell;
            end
            
            % Define the 'fingers' property - cell array of keys created
            % from finger names, to be used in get_image and get_fname
            % functions as an alternative to finger id. The keys are of
            % form '{hand}_{finger name}', where 'hand' can be 'left' or
            % 'right' and 'finger name' is one of the following: 'index',
            % 'middle', and 'ring'.
            finger_names = [string('ring'),string('middle'),string('index')];
            finger_names = [string(finger_names), string(flip(finger_names))];
            leftright = [repmat(string('left'),1,3), repmat(string('right'),1,3)];
            
            obj.fingers = cell(6,1);
            for fid = 1:6
                obj.fingers(fid) = {char(strjoin([leftright(fid), finger_names(fid)], '_'))};
            end
        end
        
        function im_fname = get_fname(obj, varargin)
            %{
            Get name of an image file. Arguments:
                - obj - the mtadata_array object,
                - 'participant' - character vector specifying participant id,
                - 'finger' - finger id number (1-6, default: 4) or key of
                finger name (refer to obj.fingers for allowed names),
                - 'measurement' - id of the measurement (1-4, default: 1),
                - 'full' - if true, return filename with full path; if
                false, return only the filename (default: false)
            Returns: im_fname - character vector.
            %}
            p = inputParser;
            addRequired(p, 'participant');
            addOptional(p, 'finger',4);
            addOptional(p, 'measurement',1, @isnumeric);
            addOptional(p, 'full', false, @islogical)
            parse(p, obj, varargin{:});
            Res = p.Results
            
            if isnumeric(Res.finger)
                finger = Res.finger;
            elseif (ischar(Res.finger) | isstring(Res.finger))
                finger = find(contains(obj.fingers, char(Res.finger)));
                if isempty(finger)
                    error('Invalid finger name; refer to fingers property for allowed names or use integer 1-6.');
                end
            else
                error('Invalid data type for finger argument');
            end
            
            keys(obj.images)
            participant_data = obj.images(Res.participant); %get cell array for given participant
            image_meta = participant_data(finger, Res.measurement); % access metadata object
                                                                   % for given finger and measurement
            % access the filename
            if Res.full
                im_fname = image_meta{1}.full_fname;
            else
                im_fname = image_meta{1}.im_fname;
            end
        end
        
        function image = get_image(obj, varargin)
            %{
            Get image with associated metadata. Arguments:
                - obj - the mtadata_array object,
                - 'participant' - character vector specifying participant id,
                - 'finger' - finger id number (1-6, default: 4) or key of
                finger name (refer to obj.fingers for allowed names),
                - 'measurement' - id of the measurement (1-4, default: 1),
            Returns: image_container object for the specified arguments.
            %}
            p = inputParser;
            addRequired(p, 'participant');
            addOptional(p, 'finger',4);
            addOptional(p, 'measurement',1, @isnumeric);
            parse(p, obj, varargin{:});
            Res = p.Results;
            
            % get filename
            im_fname = get_fname(obj, 'participant', Res.participant,...
                'finger', Res.finger, 'measurement', Res.measurement, 'full', true);
            image = image_container(im_fname); %read the image
        end
    end
end