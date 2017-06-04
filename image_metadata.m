classdef image_metadata
    %{
    Create object storing metadata extracted from the filename. Object is
    initialised given full path to the image file in a form of character
    vector or a 1x1 cell array, containing the character vector (to
    facilitate use of filenames stored in an ImageDataStore object).
    
    Properties:
        - person_id (char),
        - finger_id (integer, 1-6),
        - measurement_id (integer, 1-4),
        - datetime - datetime object,
        - im_fname (char) - name of the file,
        - full_fname (char) - name of the file including the full path.
    
    Methods:
        - obj = image_metadata(full_fname) - constructor method.
    %}
    
    properties
        person_id
        finger_id
        measurement_id
        datetime
        im_fname
        full_fname
    end
     
    methods
        function obj = image_metadata(full_fname)
            % constructor method - object initialisation
            if iscell(full_fname)
                full_fname = char(full_fname);
            end
            slashes = strfind(full_fname,'\');
            im_fname = full_fname((slashes(end)+1):end);
            
            obj.full_fname = full_fname;
            obj.im_fname = im_fname;
            
            underscores = strfind(im_fname,'_');
            obj.person_id = im_fname(1 : (underscores(1)-1));
            obj.finger_id = str2num(im_fname((underscores(1)+1) : (underscores(2)-1)));
            obj.measurement_id = str2num(im_fname((underscores(2)+1) : (underscores(3)-1)));
            datetimestr = im_fname((underscores(3)+1) : (end-4));
            obj.datetime = datetime(datetimestr, 'InputFormat', 'yyMMdd-HHmmss');
        end    

    end
end