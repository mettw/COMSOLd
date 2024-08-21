function [fname, available_projects] = set_COMSOLdStudyConfig_project(project)

    available_projects = ["Giorgio" "DARPA"];
    
    switch project
        case "Giorgio"
            fname = "C:\Users\Matthew\MATLAB Drive\Giorgio\configure_COMSOLdStudyConfig.m";
        case "DARPA"
            fname = "C:\Users\Matthew\MATLAB Drive\DARPA\configure_COMSOLdStudyConfig.m";
        otherwise
            error("COMSOLdStudyConfig(): Project not configured.");
    end
end