function out = set_COMSOLdStudyConfig_project(project)

    if isempty(project) % get list of available projects
        out = ["Giorgio" "DARPA"];
    else    
        switch project
            case "Giorgio"
                out = "C:\Users\Matthew\MATLAB Drive\Giorgio\configure_COMSOLdStudyConfig.m";
            case "DARPA"
                out = "C:\Users\Matthew\MATLAB Drive\DARPA\configure_COMSOLdStudyConfig.m";
            otherwise
                error("COMSOLdStudyConfig(): Project not configured.");
        end
    end
end