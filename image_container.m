classdef image_container
    %{
    Create object storing a finger vein image together with metadata
    extracted from the filename. Object is initialised given full path to
    the image file.
    
    Properties:
        - image - 2D double array,
        - meta - image_metadata object.
    
    Methods:
        - obj = image_container(full_fname) - constructor method.
        - show_image(obj) - create figure window to present the image
        together with summary of the metadata included in the title.
        - finger_str = name_finger(obj) - return string describing the
        finger presented in the image (left/right index/middle/ring finger).
    %}
    properties
        image
        meta
    end
    
    methods
        function obj = image_container(full_fname)
            % Constructor method - object initialisation.
            % Read the image and extract the associated metadata.
            if iscell(full_fname)
                full_fname = char(full_fname);
            end
            obj.image = im2double(imread(full_fname));
            obj.meta = image_metadata(full_fname);
        end
            
        function show_image(obj)
            % Create figure window and plot the image.
            figure();
            imshow(obj.image, [])
            
            finger_str = name_finger(obj);
            title(strjoin(['Participant ' obj.meta.person_id ', ' finger_str ' (' obj.meta.finger_id...
                '), measurement ' obj.meta.measurement_id ': '...
                datestr(obj.meta.datetime, 'dd.mm.yyyy, HH:MM:ss')], ''));
        end
        
        function finger_str = name_finger(obj)
            % Return description of the finger presented in the image
            % (left/right index/middle/ring finger).
            
            % create arrays of possible finger name parts
            finger_names = [string('ring'),string('middle'),string('index')];
            finger_names = [string(finger_names), string(flip(finger_names))];
            leftright = [repmat(string('left'),1,3), repmat(string('right'),1,3)];
            
            fid = obj.meta.finger_id; %finger id number from image_metatada
            finger_str = strjoin([leftright(fid), finger_names(fid), string('finger')]);
        end
    end
end